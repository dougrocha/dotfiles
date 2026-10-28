pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Polkit

Singleton {
    id: root

    readonly property var blankRequest: ({
            title: "",
            command: "",
            prompt: "Password",
            responseRequired: false,
            responseVisible: false,
            note: null,
            identities: [],
            selected: 0
        })
    readonly property string currentUser: Quickshell.env("USER") ?? ""

    readonly property var live: agent.flow ? readFlow(agent.flow) : null
    property var held: blankRequest
    onLiveChanged: if (live)
        held = live

    property bool active: false
    property bool submitted: false
    property bool failed: false
    property real lockedUntil: 0

    readonly property var request: held
    readonly property bool canSubmit: held.responseRequired && !submitted
    readonly property bool canChooseIdentity: held.identities.length > 1
    readonly property var status: statusFor(held, submitted, failed, lockedUntil)
    readonly property string instruction: instructionFor(held)

    signal requestStarted
    signal attemptFailed
    signal inputReset

    function submit(response: string): void {
        const flow = agent.flow;
        if (!flow?.isResponseRequired || submitted)
            return;
        submitted = true;
        failed = false;
        flow.submit(response);
    }

    function cancel(): void {
        const flow = agent.flow;
        end();
        flow?.cancelAuthenticationRequest();
    }

    function selectIdentity(index: int): void {
        const flow = agent.flow;
        if (!flow || index === held.selected)
            return;
        const identity = flow.identities[index];
        if (!identity)
            return;
        submitted = false;
        failed = false;
        flow.selectedIdentity = identity;
        inputReset();
    }

    function readFlow(flow) {
        const identities = Array.from(flow.identities ?? []);
        const note = String(flow.supplementaryMessage ?? "").trim();
        return Object.assign({}, describe(String(flow.message ?? "")), {
            prompt: String(flow.inputPrompt ?? "").trim().replace(/:\s*$/, "") || "Password",
            responseRequired: flow.isResponseRequired,
            responseVisible: flow.responseVisible,
            note: note ? {
                text: note,
                isError: flow.supplementaryIsError
            } : null,
            identities: identities.map((identity, index) => ({
                        key: index,
                        name: identity.displayName,
                        isGroup: identity.isGroup
                    })),
            selected: Math.max(0, identities.indexOf(flow.selectedIdentity))
        });
    }

    function describe(message) {
        const match = message.match(/^Authentication is (?:needed|required) to run [`'](.+)[`'] as (the super user|user (.+))$/i);
        if (!match)
            return {
                title: message.trim() || "An app wants to make changes.",
                command: ""
            };
        const program = match[1].split(/\s+/)[0].split("/").pop();
        const runsAs = match[3] ?? "root";
        return {
            title: `“${program}” wants to run as ${runsAs}.`,
            command: match[1]
        };
    }

    function instructionFor(request) {
        const identity = request.identities[request.selected];
        if (!identity || (!identity.isGroup && identity.name === currentUser))
            return "Enter your password to allow this.";
        return `Enter the password for ${identity.name} to allow this.`;
    }

    function statusFor(request, submitted, failed, lockedUntil) {
        if (lockedUntil === Infinity)
            return {
                error: true,
                text: "Too many attempts. This account is locked."
            };
        if (lockedUntil > 0) {
            const minutes = Math.max(1, Math.ceil((lockedUntil - Date.now()) / 60000));
            return {
                error: true,
                text: `Too many attempts. Try again in ${minutes} ${minutes === 1 ? "minute" : "minutes"}.`
            };
        }
        if (request.note?.isError)
            return {
                error: true,
                text: request.note.text
            };
        if (failed)
            return {
                error: true,
                text: `${request.prompt} not accepted. Try again.`
            };
        if (submitted && !request.responseRequired)
            return {
                error: false,
                text: `Checking ${request.prompt.toLowerCase()}…`
            };
        if (request.note)
            return {
                error: false,
                text: request.note.text
            };
        return null;
    }

    function lockUser() {
        const identity = held.identities[held.selected];
        return identity && !identity.isGroup ? identity.name : currentUser;
    }

    function checkLock() {
        lockCheck.command = ["faillock", "--user", lockUser()];
        lockCheck.running = true;
    }

    function confValue(key, fallback) {
        const match = faillockConf.text().match(new RegExp(`^\\s*${key}\\s*=\\s*(\\d+)`, "m"));
        return match ? Number(match[1]) : fallback;
    }

    function lockEnd(output, deny, unlockTime, failInterval) {
        if (deny <= 0)
            return 0;
        const times = output.split("\n").map(line => line.match(/^(\d{4}-\d\d-\d\d) (\d\d:\d\d:\d\d)\s.*\sV\s*$/)).filter(match => match).map(match => new Date(`${match[1]}T${match[2]}`).getTime());
        const last = times[times.length - 1];
        if (times.filter(time => last - time <= failInterval * 1000).length < deny)
            return 0;
        if (unlockTime === 0)
            return Infinity;
        const end = last + unlockTime * 1000;
        return end > Date.now() ? end : 0;
    }

    function adopt() {
        submitted = false;
        failed = false;
        lockedUntil = 0;
        active = true;
        requestStarted();
        checkLock();
    }

    function end() {
        active = false;
    }

    FileView {
        id: faillockConf

        path: "/etc/security/faillock.conf"
        printErrors: false
    }

    Process {
        id: lockCheck

        stdout: StdioCollector {
            onStreamFinished: root.lockedUntil = root.lockEnd(text, root.confValue("deny", 3), root.confValue("unlock_time", 600), root.confValue("fail_interval", 900))
        }
    }

    Timer {
        running: root.lockedUntil > 0 && root.lockedUntil !== Infinity
        interval: Math.max(1000, root.lockedUntil - Date.now())
        onTriggered: root.lockedUntil = 0
    }

    PolkitAgent {
        id: agent

        path: "/qs/PolkitAgent"

        onFlowChanged: flow ? root.adopt() : root.end()
        onIsRegisteredChanged: {
            if (isRegistered)
                console.log("quickshell polkit agent registered");
            else
                console.warn("quickshell polkit agent is not registered; another agent may be running");
        }
    }

    Connections {
        target: agent.flow

        function onIsResponseRequiredChanged() {
            if (agent.flow?.isResponseRequired) {
                root.submitted = false;
                root.inputReset();
            }
        }

        function onAuthenticationFailed() {
            root.submitted = false;
            root.failed = true;
            root.attemptFailed();
            root.checkLock();
        }

        function onAuthenticationSucceeded() {
            root.end();
        }

        function onAuthenticationRequestCancelled() {
            root.end();
        }
    }
}
