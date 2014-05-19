module ActiveAdmin
  module AsyncExport
    class AsyncExportMailer < ActionMailer::Base
      add_template_helper MethodOrProcHelper

      def csv_export(admin_email, model_name, params )
        controller = Kernel::qualified_const_get("Admin::#{model_name}sController").new
        config = controller.send(:active_admin_config)
        path = controller.send(:active_admin_template, 'index.csv')
        csv_filename = controller.send(:csv_filename)

        app = ActiveAdmin.application 
        collection = csv_collection(model_name,params)

        csv = render_to_string(file: path,
                         layout: false,
                         locals: {
                           active_admin_application: app,
                           active_admin_config: config,
                           collection: collection,
                          })

        attachments[csv_filename] = csv
        mail(to: admin_email,
             subject: csv_filename,
             body: 'See attached',
             from: ActiveAdmin::AsyncExport.from_email_address)
      end

      def csv_collection(model,params)
        klass = model.constantize
        @search = klass.search  clean_search_params params['q']

        @search.to_a
      end

      def clean_search_params(search_params)
        return {} unless search_params.is_a?(Hash)
        

        search_params = search_params.dup
        search_params.delete_if do |key, value|
          value == ""
        end
        search_params
      end

    end
  end
end
