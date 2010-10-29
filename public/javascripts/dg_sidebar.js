if(! console) { var console = {}; }
if(! console.log) { console.log = function() {}; }

var DigitalGazette = {
    Sidebar: {
        ToggleButton: {
            div: document.createElement('div'),
            width: 46, // px
            setup: function() {
                this.div.setAttribute('id', 'dg_sidebar_toggle');
                this.div.style['position'] = 'absolute';
                this.div.style['top'] = '0';
                this.div.style['left'] = '0';
                this.div.style['height'] = '100%';
                this.div.style['width'] = this.width + 'px';
                // this.div.style['background'] = '-webkit-gradient(linear, left top, left bottom, from(#ccc), to(#000))';
                // this.div.style['background'] = '-moz-linear-gradient(top,  #ccc,  #000)';
                // this.div.style['filter'] = "progid:DXImageTransform.Microsoft.gradient(startColorstr='red', endColorstr='#000000')";
                this.div.onclick = function() { DigitalGazette.Sidebar.toggle(); };

            },
        },
        div: document.createElement('div'),
        wrapper: document.createElement('div'),
        setupCbs: [],
        onsetup: function(f) {
            this.setupCbs.push(f);
        },
        setup: function() {
            if(this._is_setup)
                return;
            console.log("[Sidebar] Preparing...");
            this._is_setup = true;
            Element.extend(this.wrapper);
            Element.extend(this.div);
            this.div.setAttribute('id', 'dg_sidebar_content');
            this.wrapper.setAttribute('id', 'dg_sidebar_wrapper');
            this.wrapper.style['min-width'] = this.ToggleButton.width + 'px';
            this.div.style['padding-left'] = (this.ToggleButton.width * 1.5) + 'px';

            this.ToggleButton.setup();
            this.wrapper.appendChild(this.ToggleButton.div);
            this.wrapper.appendChild(this.div);
            document.body.appendChild(this.wrapper);
            this.div.hide();
            window.onload = window.onresize = document.onresize = function() {
                DigitalGazette.Sidebar.adjust(); };
            console.log("[Sidebar] Calling setup callbacks...");
            this.setupCbs.each(function(cb) { cb(); });
        },
        adjust: function() {
            if(! $('wrapper')) // global content wrapper. not present on login page. so we don't have a sidebar on the login page. sad that is.
                return;
            console.log("[Sidebar] Adjusting...");
            var width, height;
            // firefox 3.0.5 (amongst others) gives us invalid document.height.
            height = ($('wrapper').getHeight() - Element.positionedOffset(this.wrapper)[1] - $('footer_wrapper').getHeight());
            if(this.visible())
                width = ((window.innerWidth / 100) * 25);
            else
                width = this.ToggleButton.width;
            console.log("[Sidebar] "+width+"x"+height);
            this.wrapper.style['height'] = height + 'px';
            this.wrapper.style['width'] = width + 'px';
            // height is usually 100%, but some browsers seem to forget that when the parent changes size... had trouble in firefox.
            this.ToggleButton.div.style['height'] = height + 'px';
            var fw = $('footer_wrapper');
            fw.style['width'] = (this.visible() ? (fw.getWidth() - width + this.ToggleButton.width) + 'px' : '100%');
        },
        insert: function() {
            for(i in arguments) {
                this.div.insert(arguments[i]);
            }
        },
        replaceContent: function(cnt) {
            this.div.update(cnt)
        },
        toggle: function() {
            this.div.toggle();
            this.adjust();
        },
        visible: function() {
            return (this.div.style['display'] != 'none');
        }
    }
};

window.onload = function() { DigitalGazette.Sidebar.setup(); };
