# Vulkan SDK Setup (macOS only)
if test (uname) = "Darwin"
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
        set -gx SDL_VULKAN_LIBRARY "$VULKAN_SDK/lib/libvulkan.dylib"
        set -gx VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR 1
    end
end
