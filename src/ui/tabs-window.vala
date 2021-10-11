namespace HandyExample {
    
    [GtkTemplate (ui = "/me/paladin/HandyExample/ui/window-tabs.ui")]
    public class TabsWindow : Hdy.Window {
        [GtkChild]
        private unowned Hdy.TabView view;
        [GtkChild]
        private unowned Hdy.TabBar tab_bar;
        private ActionMap tab_action_group;
        private Hdy.TabPage menu_page;
        private static int next_page = 1;
        private const ActionEntry action_entries[] = {
            { "window-new", window_new },
            { "tab-new", tab_new },
        };
        
        private const ActionEntry tab_action_entries[] = {
            { "pin", tab_pin },
            { "unpin", tab_unpin },
            { "close", tab_close },
            { "close-other", tab_close_other },
            { "close-before", tab_close_before },
            { "close-after", tab_close_after },
            { "move-to-new-window", tab_move_to_new_window },
            { "needs-attention", null, null, "false", tab_change_needs_attention },
            { "loading", null, null, "false", tab_change_loading },
            { "indicator", null, null, "false", tab_change_indicator },
            { "icon", null, null, "false", tab_change_icon },
            { "refresh-icon", tab_refresh_icon },
            { "duplicate", tab_duplicate },
        };
        
        public TabsWindow() {
            var action_map = new SimpleActionGroup();
            action_map.add_action_entries(action_entries, this);
            insert_action_group("win", action_map);
            
            tab_action_group = new SimpleActionGroup();
            tab_action_group.add_action_entries(tab_action_entries, this);
            insert_action_group("tab", (ActionGroup) tab_action_group);
            
            var target_list = new Gtk.TargetList(null);
            target_list.add_text_targets(0);
            tab_bar.set_extra_drag_dest_targets(target_list);
        }
        
        public void window_new() {
            var window = new TabsWindow();
            
            window.prepopulate();
            window.present();
        }
        
        public Icon get_random_icon() {
            var theme = Gtk.IconTheme.get_default();
            var list = theme.list_icons("MimeTypes");
            
            int index = Random.int_range(0, (int) list.length());
            var icon = new ThemedIcon(list.nth_data(index));
            
            return icon;
        }
        
        /**
         * Add tooltip for tab hover
         */
        public bool text_to_tooltip(GLib.Binding binding, GLib.Value from_value, ref GLib.Value to_value) {
            string tooltip = Markup.printf_escaped("Tooltip for <b>%s</b>", from_value.get_string());
            
            to_value.take_string(tooltip);
            return true;
        }
        
        /**
         * Add tab contents
         */
        public Hdy.TabPage add_page(Hdy.TabPage? parent, string title, Icon icon) {
            Hdy.TabPage page;
            
            var content = new Gtk.Entry();
            content.visible = true;
            content.text = title;
            content.halign = Gtk.Align.CENTER;
            content.valign = Gtk.Align.CENTER;
            
            page = view.add_page(content, parent);
            
            content.bind_property("text", page, "title", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            content.bind_property("text", page, "tooltip", BindingFlags.SYNC_CREATE, text_to_tooltip);
            
            page.set_icon(icon);
            page.set_indicator_activatable(true);
            
            return page;
        }
        
        public void tab_new() {
            string title = @"Tab $next_page";
            
            var page = add_page(null, title, get_random_icon());
            var content = page.get_child();
            
            view.set_selected_page(page);
            content.grab_focus();
            
            next_page++;
        }
        
        public Hdy.TabPage get_current_page() {
            return menu_page ?? view.get_selected_page();
        }
        
        public void tab_pin() {
            view.set_page_pinned(get_current_page(), true);
        }
        
        public void tab_unpin() {
            view.set_page_pinned(get_current_page(), false);
        }
        
        public void tab_close() {
            view.close_page(get_current_page());
        }
        
        public void tab_close_other() {
            view.close_other_pages(get_current_page());
        }
        
        public void tab_close_before() {
            view.close_pages_before(get_current_page());
        }
        
        public void tab_close_after() {
            view.close_pages_after(get_current_page());
        }
        
        public void tab_move_to_new_window() {
            var window = new TabsWindow();
            
            view.transfer_page(menu_page, window.view, 0);
            
            window.present();
        }
        
        public void tab_change_needs_attention(SimpleAction action, Variant parameter) {
            bool need_attention = parameter.get_boolean();
            
            get_current_page().set_needs_attention(need_attention);
            action.set_state(new Variant.boolean(need_attention));
        }
        
        public void tab_change_loading(SimpleAction action, Variant parameter) {
            bool loading = parameter.get_boolean();
            
            get_current_page().set_loading(loading);
            action.set_state(new Variant.boolean(loading));
        }
        
        public Icon get_indicator_icon(Hdy.TabPage page) {
            bool muted = page.get_data<bool>("hdy-tab-view-demo-muted");
            
            if (muted)
                return new ThemedIcon("audio-volume-muted-symbolic");
            else
                return new ThemedIcon("audio-volume-high-symbolic");
        }
        
        public void tab_change_indicator(SimpleAction action, Variant parameter) {
            bool indicator = parameter.get_boolean();
            Icon icon = null;
            
            if (indicator)
                icon = get_indicator_icon(get_current_page());
            
            get_current_page().set_indicator_icon(icon);
            action.set_state(new Variant.boolean(indicator));
        }
        
        public void tab_change_icon(SimpleAction action, Variant parameter) {
            bool enable_icon = parameter.get_boolean();
            
            if (enable_icon) {
                get_current_page().set_icon(get_random_icon());
            } else {
                get_current_page().set_icon(null);
            }
            
            action.set_state(new Variant.boolean(enable_icon));
        }
        
        public void tab_refresh_icon() {
            get_current_page().set_icon(get_random_icon());
        }
        
        public void tab_duplicate() {
            var parent = get_current_page();
            var page = add_page(parent, parent.title, parent.icon);
            
            page.set_indicator_icon(parent.get_indicator_icon());
            page.set_loading(parent.get_loading());
            page.set_needs_attention(parent.get_needs_attention());
            
            page.set_data<bool>("hdy-tab-view-demo-muted", parent.get_data<bool>("hdy-tab-view-demo-muted"));
            
            view.set_selected_page(page);
        }
        
        public void set_tab_action_enabled(string name, bool enabled) {
            var action = tab_action_group.lookup_action(name);
            
            if (action is SimpleAction) {
                action.set_enabled(enabled);
            }
        }
        
        public void set_tab_action_state(string name, bool state) {
            var action = tab_action_group.lookup_action(name);
            
            if (action is SimpleAction) {
                action.set_state(new Variant.boolean(state));
            }
        }
        
        [GtkCallback]
        private void setup_menu_cb(Hdy.TabView view, Hdy.TabPage? page) {
            menu_page = page;
            Hdy.TabPage prev = null;
            bool pinned = false,
                 prev_pinned,
                 has_icon = false,
                 can_close_before = true,
                 can_close_after = true;
            
            var n_pages = view.get_n_pages();
            int pos;
            
            if (page != null) {
                pos = view.get_page_position(page);
                
                if (pos > 0)
                    prev = view.get_nth_page(pos - 1);
                
                pinned = page.pinned;
                prev_pinned = prev != null && prev.pinned;
                
                can_close_before = !pinned && prev != null && !prev_pinned;
                can_close_after = pos < n_pages - 1;
                
                has_icon = page.get_icon() != null;
            }
            
            set_tab_action_enabled("pin", page == null || !pinned);
            set_tab_action_enabled("unpin", page == null || pinned);
            set_tab_action_enabled("close", page == null || !pinned);
            set_tab_action_enabled("close-before", can_close_before);
            set_tab_action_enabled("close-after", can_close_after);
            set_tab_action_enabled("close-other", can_close_before || can_close_after);
            set_tab_action_enabled("move-to-new-window", page == null || (!pinned && n_pages > 1));
            set_tab_action_enabled("refresh-icon", has_icon);
            
            if (page != null) {
                set_tab_action_state("icon", has_icon);
                set_tab_action_state("loading", page.get_loading());
                set_tab_action_state("needs-attention", page.get_needs_attention());
                set_tab_action_state("indicator", page.get_indicator_icon() != null);
            }
        }
        
        [GtkCallback]
        private unowned Hdy.TabView? create_window_cb(Hdy.TabView view) {
            var window = new TabsWindow();
            
            window.set_position(Gtk.WindowPosition.MOUSE);
            window.present();
            
            return window.view;
        }
        
        [GtkCallback]
        private void indicator_activated_cb(Hdy.TabPage page) {
            var muted = page.get_data<bool>("hdy-tab-view-demo-muted");
            
            page.set_data<bool>("hdy-tab-view-demo-muted", !muted);
            
            page.set_indicator_icon(get_indicator_icon(page));
        }
        
        [GtkCallback]
        private void extra_drag_data_received_cb(
                Hdy.TabPage page,
                Gdk.DragContext context,
                Gtk.SelectionData selection_data
        ) {
            page.set_title(selection_data.get_text());
        }
        
        public void prepopulate() {
            tab_new();
            tab_new();
            tab_new();
        }
    }
}
