<?php
/**
 * GeneratePress.
 *
 * Please do not make any edits to this file. All edits should be done in a child theme.
 *
 * @package GeneratePress
 */

if ( ! defined( &#039;ABSPATH&#039; ) ) {
        exit; // Exit if accessed directly.
}

// Set our theme version.
define( &#039;GENERATE_VERSION&#039;, &#039;3.6.1&#039; );

if ( ! function_exists( &#039;generate_setup&#039; ) ) {
        add_action( &#039;after_setup_theme&#039;, &#039;generate_setup&#039; );
        /**
         * Sets up theme defaults and registers support for various WordPress features.
         *
         * @since 0.1
         */
        function generate_setup() {
                // Make theme available for translation.
                load_theme_textdomain( &#039;generatepress&#039; );

                // Add theme support for various features.
                add_theme_support( &#039;automatic-feed-links&#039; );
                add_theme_support( &#039;post-thumbnails&#039; );
                add_theme_support( &#039;post-formats&#039;, array( &#039;aside&#039;, &#039;image&#039;, &#039;video&#039;, &#039;quote&#039;, &#039;link&#039;, &#039;status&#039; ) );
                add_theme_support( &#039;woocommerce&#039; );
                add_theme_support( &#039;title-tag&#039; );
                add_theme_support( &#039;html5&#039;, array( &#039;search-form&#039;, &#039;comment-form&#039;, &#039;comment-list&#039;, &#039;gallery&#039;, &#039;caption&#039;, &#039;script&#039;, &#039;style&#039; ) );
                add_theme_support( &#039;customize-selective-refresh-widgets&#039; );
                add_theme_support( &#039;align-wide&#039; );
                add_theme_support( &#039;responsive-embeds&#039; );

                $color_palette = generate_get_editor_color_palette();

                if ( ! empty( $color_palette ) ) {
                        add_theme_support( &#039;editor-color-palette&#039;, $color_palette );
                }

                add_theme_support(
                        &#039;custom-logo&#039;,
                        array(
                                &#039;height&#039; =&gt; 70,
                                &#039;width&#039; =&gt; 350,
                                &#039;flex-height&#039; =&gt; true,
                                &#039;flex-width&#039; =&gt; true,
                        )
                );

                // Register primary menu.
                register_nav_menus(
                        array(
                                &#039;primary&#039; =&gt; __( &#039;Primary Menu&#039;, &#039;generatepress&#039; ),
                        )
                );

                /**
                 * Set the content width to something large
                 * We set a more accurate width in generate_smart_content_width()
                 */
                global $content_width;
                if ( ! isset( $content_width ) ) {
                        $content_width = 1200; /* pixels */
                }

                // Add editor styles to the block editor.
                add_theme_support( &#039;editor-styles&#039; );

                $editor_styles = apply_filters(
                        &#039;generate_editor_styles&#039;,
                        array(
                                &#039;assets/css/admin/block-editor.css&#039;,
                        )
                );

                add_editor_style( $editor_styles );
        }
}

/**
 * Get all necessary theme files
 */
$theme_dir = get_template_directory();

require $theme_dir . &#039;/inc/theme-functions.php&#039;;
require $theme_dir . &#039;/inc/defaults.php&#039;;
require $theme_dir . &#039;/inc/class-css.php&#039;;
require $theme_dir . &#039;/inc/css-output.php&#039;;
require $theme_dir . &#039;/inc/general.php&#039;;
require $theme_dir . &#039;/inc/customizer.php&#039;;
require $theme_dir . &#039;/inc/markup.php&#039;;
require $theme_dir . &#039;/inc/typography.php&#039;;
require $theme_dir . &#039;/inc/plugin-compat.php&#039;;
require $theme_dir . &#039;/inc/block-editor.php&#039;;
require $theme_dir . &#039;/inc/class-typography.php&#039;;
require $theme_dir . &#039;/inc/class-typography-migration.php&#039;;
require $theme_dir . &#039;/inc/class-html-attributes.php&#039;;
require $theme_dir . &#039;/inc/class-theme-update.php&#039;;
require $theme_dir . &#039;/inc/class-rest.php&#039;;
require $theme_dir . &#039;/inc/deprecated.php&#039;;

if ( is_admin() ) {
        require $theme_dir . &#039;/inc/meta-box.php&#039;;
        require $theme_dir . &#039;/inc/class-dashboard.php&#039;;
}

/**
 * Load our theme structure
 */
require $theme_dir . &#039;/inc/structure/archives.php&#039;;
require $theme_dir . &#039;/inc/structure/comments.php&#039;;
require $theme_dir . &#039;/inc/structure/featured-images.php&#039;;
require $theme_dir . &#039;/inc/structure/footer.php&#039;;
require $theme_dir . &#039;/inc/structure/header.php&#039;;
require $theme_dir . &#039;/inc/structure/navigation.php&#039;;
require $theme_dir . &#039;/inc/structure/post-meta.php&#039;;
require $theme_dir . &#039;/inc/structure/sidebars.php&#039;;
require $theme_dir . &#039;/inc/structure/search-modal.php&#039;;


// Front Page Centered Welcome Overlay (No Clicks)
function custom_homepage_welcome_locked() {
    if ( is_front_page() ) {
        echo '
        <style>
        /* Full screen overlay */
        .custom-welcome-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(28, 200, 138, 0.1); /* semi-transparent green */
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            z-index: 9999;
            
        }

        /* Prevent clicks on anything below */
        .custom-welcome-overlay::before {
            content: "";
            position: absolute;
            top:0; left:0;
            width:100%;
            height:100%;
            background: transparent;
            pointer-events: all;
        }

        /* Blink text */
        .custom-welcome-overlay h1 {
            font-size: 60px;
            color: red;
            margin-bottom: 15px;
            /*animation: blink 3s infinite;*/
            text-align: center;
            position: relative;
            z-index: 1;
            font-weight: bold;
        }

        .custom-welcome-overlay p {
            font-size: 24px;
            color: white;
            text-align: center;
            position: relative;
            z-index: 1;
        }

        @keyframes blink {
            0%, 50%, 100% { opacity: 1; }
            25%, 75% { opacity: 0; }
        }
        </style>

        <div class="custom-welcome-overlay">
            <h1>Afghanistan will not be silenced.
Every strike reminds sovereignty cannot be violated without consequences
Call to all Afghans worldwide
Unite against Pakistan</h1>


<marquee style="color: red; font-size: 28px; font-weight: bold;">
 All Afghans unite against Pakistan
</marquee>
                    </div>
        ';
    }
}
add_action( 'wp_head', 'custom_homepage_welcome_locked' );
