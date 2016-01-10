module RAI
  class AssetsManager

    include Common

    def update_application_view
      update_file_with_content('app/views/layouts/application.haml', content_for_view, 'app/views/layouts/application.html.erb')
    end

    def update_application_css
      update_file_with_content('app/assets/stylesheets/application.scss', content_for_css, 'app/assets/stylesheets/application.css')
    end

    def update_application_js
      update_file_with_content('app/assets/javascripts/application.js', content_for_js)
    end

    private

    def content_for_view
      turbolinks_track = use_turbolinks? ? ", 'data-turbolinks-track' => true" : ''
      <<-CONTENT
!!!
%html
  %head
    %title #{config.app_name}
    = stylesheet_link_tag    'application', media: 'all'#{turbolinks_track}
    = javascript_include_tag 'application'#{turbolinks_track}
    = csrf_meta_tags
  %body
    = yield
      CONTENT
    end

    def content_for_js
      turbolinks = use_turbolinks? ? '//= require turbolinks' : '//'
      <<-CONTENT
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require jquery.remotipart
#{turbolinks}
// require_tree .
      CONTENT
    end

    def content_for_css
      <<-CONTENT
@charset "utf-8";
      CONTENT
    end

  end
end
