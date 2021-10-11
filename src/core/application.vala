namespace HandyExample {
    
    public class Application : Gtk.Application {
        private MainWindow window;
        
        public Application() {
            application_id = "me.paladin.HandyExample";
        }
        
        public override void activate() {
            base.activate();
            
            window = new MainWindow(this);
            window.present();
        }
        
        public override void startup() {
            base.startup();
            
            Hdy.init();
        }
        
    }
}
