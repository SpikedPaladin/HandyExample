namespace HandyExample {
    
    [GtkTemplate (ui = "/me/paladin/HandyExample/ui/window-main.ui")]
    public class MainWindow : Hdy.Window {
        [GtkChild]
        private unowned Gtk.Button run;
        
        public MainWindow(Gtk.Application application) {
            Object(application: application);
            
            run.clicked.connect(() => {
                var window = new TabsWindow();
                window.prepopulate();
                window.present();
            });
        }
    }
}
