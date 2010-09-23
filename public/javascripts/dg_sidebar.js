var DigitalGazette = {
    Sidebar: {
        ToggleButton: {
            div: document.createElement('div'),
            width: 16, // px
            setup: function() {
                this.div.setAttribute('id', 'dg_sidebar_toggle');
                this.div.style['position'] = 'absolute';
                this.div.style['top'] = '0';
                this.div.style['left'] = '0';
                this.div.style['height'] = '100%';
                this.div.style['width'] = this.width + 'px';
                this.div.style['background'] = 'red'; // TODO: remove this.
                this.div.onclick = function() { DigitalGazette.Sidebar.toggle(); };
            },
        },
        div: document.createElement('div'),
        wrapper: document.createElement('div'),
        setup: function() {
	    if(this._is_setup)
		return;
	    this._is_setup = true;
            Element.extend(this.wrapper);
            Element.extend(this.div);
            this.div.setAttribute('id', 'dg_sidebar');
            this.wrapper.style['position'] = 'absolute';
            this.wrapper.style['top'] = '160px';
            this.wrapper.style['right'] = '0';
            this.div.style['height'] = '100%';
            this.div.style['width'] = '100%';
            this.div.style['padding-left'] = this.ToggleButton.width * 1.5;
            this.div.style['background'] = 'blue'; // TODO: remove this.
            this.ToggleButton.setup();
            this.wrapper.appendChild(this.ToggleButton.div);
            this.wrapper.appendChild(this.div);
            document.body.appendChild(this.wrapper);
            var self = this;
            window.onload = function() { self.adjust(); };
            window.onresize = function() { self.adjust(); };
            document.onresize = function() { self.adjust(); };
        },
        adjust: function() {
            this.wrapper.style['height'] = (document.height - Element.positionedOffset(this.wrapper)[1] - $('footer_wrapper').getHeight()) + 'px';
            if(this.visible())
                this.wrapper.style['width'] = ((window.innerWidth / 100) * 25) + 'px';
            else
                this.wrapper.style['width'] = this.ToggleButton.width + 'px';
        },
        insert: function() {
            for(i in arguments) {
                this.div.innerHTML += arguments[i] + "\n";
            }
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
