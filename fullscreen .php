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
