# frozen_string_literal: true

module DeviseSecurity::Patches
  module RegistrationsControllerCaptcha
    extend ActiveSupport::Concern
    included do
      define_method :create do |&block|
        build_resource(sign_up_params)

        if valid_captcha_if_defined?(params[:captcha])
          if resource.save
            block&.call(resource)
            if resource.active_for_authentication?
              set_flash_message :notice, :signed_up if is_flashing_format?
              sign_up(resource_name, resource)
              respond_with resource, location: after_sign_up_path_for(resource)
            else
              set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
              expire_data_after_sign_in!
              respond_with resource, location: after_inactive_sign_up_path_for(resource)
            end
          else
            clean_up_passwords resource
            respond_with resource
          end

        else
          resource.errors.add :base, t('devise.invalid_captcha')
          clean_up_passwords resource
          respond_with resource
        end
      end
    end
  end
end
