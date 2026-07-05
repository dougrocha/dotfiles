# Vulkan SDK Setup (macOS only)
if test (uname) = "Darwin"
    # Try latest symlink first, then fall back to specific version
    if test -d "$HOME/VulkanSDK/latest/macOS"
        set -gx VULKAN_SDK $HOME/VulkanSDK/latest/macOS
    else if test -d "$HOME/VulkanSDK/1.4.350.1/macOS"
        set -gx VULKAN_SDK $HOME/VulkanSDK/1.4.350.1/macOS
    end

    if test -d "$VULKAN_SDK"
        fish_add_path "$VULKAN_SDK/bin"
        set -gx DYLD_LIBRARY_PATH "$VULKAN_SDK/lib" $DYLD_LIBRARY_PATH
        set -gx VK_LAYER_PATH "$VULKAN_SDK/share/vulkan/explicit_layer.d:/opt/homebrew/opt/vulkan-validationlayers/share/vulkan/explicit_layer.d"
        set -gx VK_ICD_FILENAMES "$VULKAN_SDK/share/vulkan/icd.d/MoltenVK_icd.json"
        set -gx PKG_CONFIG_PATH "$VULKAN_SDK/lib/pkgconfig" $PKG_CONFIG_PATH
    end
end
