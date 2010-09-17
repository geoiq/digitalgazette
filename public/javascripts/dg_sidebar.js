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
                 this.div.style['background'] = 'red';
                 this.div.onclick = function() { DigitalGazette.Sidebar.toggle(); };
            },
        },
        div: document.createElement('div'),
        setup: function() {
            Element.extend(this.div);
            this.div.setAttribute('id', 'dg_sidebar');
             this.div.style['position'] = 'absolute';
             this.div.style['top'] = '160px';
             this.div.style['right'] = '0';
             this.div.style['background'] = 'blue';
            this.ToggleButton.setup();
            this.div.appendChild(this.ToggleButton.div);
            document.body.appendChild(this.div);
            this.adjust();
            var self = this;
            window.onresize = function() { self.adjust(); };
        },
        adjust: function() {
            this.div.style['height'] = (window.innerHeight - Element.positionedOffset(this.div)[1]) + 'px';
            this.div.style['width'] = ((window.innerWidth / 100) * 25) + 'px';
        },
        insert: function() {
            for(i in arguments) {
                this.div.innerHTML += arguments[i] + "\n";
            }
        },
        toggle: function() {
            if(this.div.style['right'] == '0px')
                this.hide();
            else
                this.show();
        },
        show: function() {
            this.div.style['right'] = '0';
        },
        hide: function() {
            this.div.style['right'] = -1 * (this.div.getWidth() - this.ToggleButton.width) + 'px';
        },
    }
};

window.onload = function() { DigitalGazette.Sidebar.setup(); };
