
var Sidebar = {
    div: document.createElement('div'),
    setup: function() {
        this.div.setAttribute('id', 'overlay-sidebar');
        this.div.style['position'] = 'absolute';
        this.div.style['top'] = '160px';
        this.div.style['right'] = '0';
        this.div.style['background'] = 'blue';
        this.adjust();
        document.body.appendChild(this.div);
        var self = this;
        window.onresize = function() { self.adjust(); };
    },
    adjust: function() {
        this.div.style['height'] = (window.innerHeight - Element.positionedOffset(this.div)[1]) + 'px';
        this.div.style['width'] = ((window.innerWidth / 100) * 25) + 'px';
    }
};
