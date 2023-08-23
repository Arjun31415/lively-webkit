use gtk::{glib, prelude::*, ApplicationWindow};
use webkit::{prelude::*, WebView};

fn main() -> glib::ExitCode {
    let app = gtk::Application::new(Some("org.gnome.webkit6-rs.example"), Default::default());
    app.connect_activate(move |app| {
        let window = ApplicationWindow::new(app);
        let webview = WebView::new();
        let settings = webkit::prelude::WebViewExt::settings(&webview).unwrap();
        settings.set_enable_webgl(true);

        webview.load_uri("https://get.webgl.org/");
                                 //
        window.set_child(Some(&webview));

        let settings = WebViewExt::settings(&webview).unwrap();
        settings.set_enable_developer_extras(true);

        /* let inspector = webview.inspector().unwrap();
        inspector.show(); */

        /* webview.evaluate_javascript(
            "alert('Hello');",
            None,
            None,
            gtk::gio::Cancellable::NONE,
            |_result| {},
        ); */
        /* webview.evaluate_javascript("42", None, None, gtk::gio::Cancellable::NONE, |result| {
            match result {
                Ok(value) => {
                    println!("is_boolean: {}", value.is_boolean());
                    println!("is_number: {}", value.is_number());
                    println!("{:?}", value.to_boolean());
                }
                Err(error) => println!("{}", error),
            }
        }); */
        window.present();
    });
    app.run()
}
