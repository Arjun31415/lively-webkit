use gtk::{glib, prelude::*, Application, ApplicationWindow};
use webkit::{prelude::*, WebView};

fn main() -> glib::ExitCode {
    let app = gtk::Application::new(Some("org.gnome.webkit6-rs.example"), Default::default());
    app.connect_activate(build_ui);
    app.run()
}
fn build_ui(app: &Application) {
    let window = ApplicationWindow::new(app);
    let webview = WebView::new();
    let settings = webkit::prelude::WebViewExt::settings(&webview).unwrap();
    settings.set_enable_webgl(true);
    webview.load_uri("https://get.webgl.org/");
    window.set_child(Some(&webview));
    gtk_layer_shell::init_for_window(&window);
    gtk_layer_shell::set_exclusive_zone(&window, -1);
    gtk_layer_shell::set_layer(&window, gtk_layer_shell::Layer::Background);
    gtk_layer_shell::set_margin(&window, gtk_layer_shell::Edge::Left, 0);
    gtk_layer_shell::set_margin(&window, gtk_layer_shell::Edge::Right, 0);
    gtk_layer_shell::set_margin(&window, gtk_layer_shell::Edge::Top, 0);
    gtk_layer_shell::set_anchor(&window, gtk_layer_shell::Edge::Left, true);
    gtk_layer_shell::set_anchor(&window, gtk_layer_shell::Edge::Top, true);
    gtk_layer_shell::set_anchor(&window, gtk_layer_shell::Edge::Right, true);
    gtk_layer_shell::set_anchor(&window, gtk_layer_shell::Edge::Bottom, true);
    let settings = WebViewExt::settings(&webview).unwrap();
    settings.set_enable_developer_extras(true);
    window.present();
}
