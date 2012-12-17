Eripme::Application.config.after_initialize do
  require ::Rails.root.to_s + "/lib/installation"
  Installation.load!
end
