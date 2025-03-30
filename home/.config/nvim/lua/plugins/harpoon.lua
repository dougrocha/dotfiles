return {
  'ThePrimeagen/harpoon',
  event = 'VimEnter',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local harpoon = require('harpoon')

    harpoon:setup({
      settings = {
        save_on_toggle = true,
      },
    })

    vim.keymap.set('n', '<leader>h', function()
      harpoon:list():add()
      vim.notify('󱡅 file marked' .. vim.fn.expand('%:t'), vim.log.levels.INFO)
    end, { desc = 'Add current file to harpoon' })

    for i = 1, 5 do
      vim.keymap.set(
        'n',
        '<leader>' .. i,
        function() harpoon:list():select(i) end,
        { desc = 'Select harpoon item ' .. i }
      )
    end

    vim.keymap.set(
      'n',
      '<C-e>',
      function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { desc = 'Toggle harpoon menu' }
    )
  end,
}
-- ~!~~:..:~^:..  :.          .BG  ..       ..^~~:  ..      ..  ..  :.      . .78:.:                            ....:..^J5J~:^~!!!J?^.^JYYYYJ?!77??77??YG
-- 7:^!^:~!~:...              :#Y.:^....      .::.          .::.   ..          ~:  ^~^:..                          :~::!JJ?~::^^^~!!~^^~^^~~77~~7?JYYY5PG
-- Y5Y7~~~~^:..:.             ~&?.......           .. ....:^:...    ..             .~!^.                           .:....:^^~7!^:~~~~^^:..^^^!JYJ?JJYY5GG
-- J7??~..    :~^...        ..J#:  .....   .......:^::::..^~^::.   .::                            .... ....                 ...:^^^~!??7777^^~!?J55JJ55PP
-- 7^!!.                  ....PB  ..:. ......::...:^^.....:^^:..   .^!^                ...::^^^~~~~~~~~~!!!~^:.....            .::^!J5YYJJJ?7!!!?Y555555G
-- ?~^:..  ...  ..     ..::. .BG....   ..::.  ..  ........:::.       ..         ..::^~!!~!!!7?JJ?????JJJJJYYYYY5YYJ7?7!~^^:      .:~7?7!~!?YY?!7Y55YYYY5G
-- J~..:...::.  .. .......   ^&5::... ....::....       .  .                 .^~!!!!7777!!!?Y5PPPPPPPPP555YYYYYYY55PPPPPPPP5Y7^.    .^7!^^7JJ?JJ7??J?JYYYP
-- J~:~~~!!!^..^~:..     ..  !&7. .:::::::... .:.                       :~7??????JJJY55PGB#BBBGGGGGGGGB#&&&&#BGP5555PPGGGGGGGGP5?^:.~??!~7??77!^^?Y5P5YJ5
-- ?J7:.75?JY77?!^::...    ..Y&~.::~!~!^........        .            .~?JJJJJJJYY5GBGPYJ?7!~^^^^^^^^^^^!P@@@@@@&#BBGGGGGGGGGGGGGGGPJ~!7JJY7^:^~~!J5PPPPYJ
-- ?!::^?YJ7??!: .:::::     .PB:.^^~7?7^:^^~~^^:   .:.            .~7YYYYYJY55PB#&&G7!!7?JJ7~::::~!??!~:^B@@@@@@&&#BBBBGGGGGGGGGGGGGY~!JY5J7!!!77?Y5PPP5Y
-- ?!!77!!7^:~^     .:.     .BP.:~^^^^~~!!^:^^:. .:::.          ^J55YYYYY55PGB&@@@#?!!7?77?J?~::!JYJ??YJ!5@@@@@@@@&&#BBBBGGGGGGGGGGGG775555YJ?7!!?Y5555PG
-- ~~7!^:^!~^~^:^^^^^!^^^   .&7 .~~~~::^^..::.  ..::...      .7YP555YYY5PPGBB&@@@@G!^^~!??7!~^:.^7?J?J?7!J&@@@@@@@&&&##BBBGGGGGGGPPPY..~?!!!~!!~^7Y5PPPPG
-- 77!~^^^^^^::#PYYP&5YYP~::7#7:^~7???7!!~!!!~~77~~~~~~~~^^^75PPPPPPPPPPGGGBB&@@@&5~::..::::::..::::^^::^!#@@@@@@@&&######BGGGPPGP5?:..~!^^^~77^:^~~7Y55P
-- ?7^^^:::^:..#5JJ5&YJJP&YYYYYYYG#YYY5YYY##JYY5YYY&BYYY5YY5&PJJYYJJP&5JJ5YJJG@@@&5~^::::^~^^^::^^^~:...:^B&&@@@@&&&&&BB##BGPPPPY!^:..~7?7^^!JJ7~^:::!?77
-- 7~:.....::..#5JJ5&YJJP&PPP&PJJG&JJY&YJJ##JJ5&YJJ&BJJP#JJY&PJJBBJJ5&YJJ#GJJP&&@&P7~^^~777JPGYYGG5777^^~?B&&@@@&&&&&&#B&#BGPPY7^.:^::!JJ^.:!!!777777JYJJ
-- ^:.. ...:::^&5JJ5&YJJ5GGP5PYJJG&JJY&5JJ##JJ5&YJJ&BJJP&JJY&PJJBBJJ5&YJJ#GJJP#&&&B5?!?PP5PGP5YJ5GBGPGY7JG#&@@@@&#&&&&###BG5?^^!!^^^:.^7?^.:~^::~7JYY55JJ
-- :.........:^&5JJJYJJJP&YJJ#PJJG&JJY&5JJ##JJ5&YJJ&BJJP&JJY&PJJBBJJ5&YJJ#GJJP##&@#G5?GBPGJ~^^::^^~5BBBY5B&&@@@@&#&&&&#BGJ~. ..^~^:.:^^^~!~!?7!~~!7?JJ?J5
-- ^::....   .~&5JJYBYJJP&YJJ#GJJG&JJJ5JJY&#JJYPYYY&BJJP&JJY&PJJB#JJ5&YJJ#GJJP###&&GPPPP!7GBBBBGPGGP?5GGB&@@@&@@&&###G5!.       .....:..::^7YJ!^::^~!^:^?
-- ~^:.....   :&5JJ5&YJJP&YJJBPJ?G&JJYGJJJ##JJYGGP~PBJJ5BJJY&PJJGGJJ5&YJJ#G??P#BB#&#BBGG!:~7~~~~~7J77P##&@@@@@@&#GPJ~^:.         .   ...:::~7J?!^^~~~::!?
-- ~^^::......:&GPPP&GPPG&GPPPPP5G&PPP&GP5##5PPJ7!:P#PPPPPPP&BPPPPPPG@GPP&#PPGBBBB#&##BB57!?Y5P5P5YYG#&@@@@@@@@&G7.   .   ..........  .::.  :~~~:.:~!~~?Y
-- ^^^^. .:::..~~~^:~!7!~7Y&B?7!JJ555YYYY5JYJ7~~!!^^7777~^!7??7!!?Y?77??JJY5P55PGB###&&&&BYJJ5PPGGB#&@@@@@@@@@&#BG5!:..    ........   .~^.  .^!!:..:^^~7Y
-- ..::..  ..         .^~!J#?:~PYJJY5JJJY5JJYY77?J?7!7??7~!7??7~:^.          ..:~!?YB&@@@@&#BGGB###&&@@@@@@@@@#BGPPGGPY??7^..    ....  ..  .::~?J7~^::!77
--   .::.              .:^5#. !&JJJB&JJJG&JJJB&JJJ5YYJ##JYYPYYYP?!:::~~^:....:::::^^Y#&@@@@@&&&&&&&&&&@@@@@@@&#GGGBG555&@@@@&#P7::^::^:    .:^!?JJ7..^!~7
--   ...                  PB  ~&JJJB&JJJB&JJJB&PPP&5JJ##JJ5&YJJGYJJJJYJ?7!:..:~777!~^!Y#&&@&&&@@&@@@@@@@@@@&#BGBBBGPPP#@@@@@@@&57!~~~^:.... .:^~77~^^:^75
--         .             .BG. !&JJJB&JJJB&JJJPPG55PYJJ##JJ5&YJYP77!!7JJ??7!~~~!!!!~~~~^^YG##&&&&@@@@@@@@@&###BPGG5Y5YP@@@@@@@@Y?7?7!777:.^~~^^!?J?7??!~!5
-- . ..    .    ...  ..  :&?  !&YYJB&YYJB&YYJB&JJY&5JJ##JY5&5YY5~^.:^!!!!!7???J?~:^!77:.^J5PGBB&&&&@&&&&&#BGBBP55YYJJ#@@@@@@@B77?JJJ???^.....:!!!~^~7~.:7
-- ......:...............?&~  ~&YYYB&YYYB&YYYB&YYY&PYY##YY5&5Y5Y.........::^~!77.^5BP^..^!?5BGG#BB####B##BPPGPYY5YJJ5@@@@@@@@GJYJYYJJJJ^...........^?J7!7
-- .:::::^^:::...........P#:..~&YYYB&YYYB&YYYB&YYY#5YY##YY5&5Y5J...............:JBBJ:.::~~7?Y5PG5YPPBB5PPPPPYYJYY?J?G@@@@@@@@G555YY5YYJ::........:^^~!!~?
-- ^!!~~^^^:......^^:.:.:#B:..!&GGGB&GGGB&GGGB&GGGGGGG#&GGG&BGGJ.:............^G#G~..::^~!J??7JY5G5?J5PP?J5J??YJ???J&@@@@@@@@P5P55Y555?^:::::::::~~~~~^^!
-- ^~!!^::^:.....:^^::::!&5.:::!!!!^7J5PJJJ??7Y5J7!!!~:~~!~~!77^:::^^...:::..~BB5^.:.^:~~~~?7JY?JYP5J?JJY5?7?JY?JJY5@@@@@@@@@BP5P5Y5PP7~^^^^^::^^!!!!!!!7
-- ^:^^::::::::..::^~^::Y@7:^::....::^~~^^~^:^77!~^:........:^~^::!?~::^~^..~BBP^.^::^:^!!!7!?JJY!??Y5?7YJ77JJ?JYY5B@@@@@@@@@BPGGP5PGG?!~~!!~^^^~!!!!777?
-- ~~~^::::::::::^~~^^^~B&^:::::::^^:::::::::~JJ7!^::^~~~^::^^~^^~!??!~~^.:~GBG~.:::^^~:^!77?77J?JJ7J?J5Y7??J7?JJYY#@@@@@@@@&GP#BPPGBG?7!!!!!~~~!7777777J
-- !!~^^^:::^^^~~~~^^~!7&#^^:::^^^^^:::^^^^^^!?7?7!^^^~^^^^^^^~~!!777!~^::^PB#?.:^:^^^~7!~!??7?77?JJJ7JY?7?J??JJYY5@@@@@@@@@&PPB#BG##B?777!!!~~!77777777J
-- ~!!~~~~^^^~~~~~~!!!!J&G~^^^^^^^^^^:^^^^~~~~~~!!~^^^^^^^^~~~~~!!!!!~::::JBBJ:::^:~~~~~7J7!7J?7?7?J??5J?7JJ?JJY5YG@@@@@@@@@#PB#&&###G?7777!!!!7J???JJJJY
-- 7~~~^!7!~^^^!?7!!?JJP#GY!^^^^~^^~~~^^~7??7!~~~~^^^^^^~~~~~~~~~^^~~^^::!G#Y::^~^^^~!!!!!?J!77JJ??7JYJ7?JYJ?JJ555B@@@@@@@@@#GG#&&&BG5???777777JYYJ~^^?Y5
-- J7777???!~~~!!~~?GB#&&&B!~~~~~~~~!~~!7JJ7!!!~~~~~~~~~~~~~!777!~~~~^^^^5#P^^^^^^!~~!J7J?77?J77?JJ7JYJJJYJJJJYP5P&@@@@@@@@&GBB#&@@BGY???????7?YYYY^^^755
-- YJJJ?7!~~!!!!77?5#&&#&#G7~~~~!77!!!?JYJ?!!!7!!!~~~~~~!!!7??77!!77~^^^!BB!^^^~^!~7J!!JY7?77?YY7?JYPJJ5Y55Y555PPG@@@@@@@@@&BGGB&@@BG5JJJ?????JY55YJJYY55
