require_dependency "no_cms/admin/menus/application_controller"

module NoCms::Admin::Menus
  class MenusController < ApplicationController

    before_filter :load_menu_section
    before_filter :load_menus, only: [:index, :new, :edit]
    before_filter :load_menu, only: [:edit, :update, :destroy]

    def new
      @menu = NoCms::Menus::Menu.new
    end

    def create
      @menu = NoCms::Menus::Menu.new menu_params
      if @menu.save
        @nocms_logger.info(I18n.t('.no_cms.admin.menus.menus.create.success', title: @menu.name), true)
        redirect_to edit_menu_path(@menu)
      else
        @nocms_logger.error(I18n.t('.no_cms.admin.menus.menus.create.error', title: @menu.name))
        load_menus
        render :new
      end
    end

    def edit
      @nocms_logger.add_message :menus, I18n.t('.no_cms.admin.menus.menus.edit.log_messages', title: @menu.name)
      load_menu_item_templates
    end

    def update
      if @menu.update_attributes menu_params
        @nocms_logger.info(I18n.t('.no_cms.admin.menus.menus.update.success', title: @menu.name), true)
        redirect_to edit_menu_path(@menu)
      else
        @nocms_logger.error(I18n.t('.no_cms.admin.menus.menus.update.error', title: @menu.name))
        load_menus
        load_menu_item_templates
        render :edit
      end
    end

    def destroy
      if @menu.destroy
        @nocms_logger.info(I18n.t('.no_cms.admin.menus.menus.destroy.success', title: @menu.name), true)
      else
        @nocms_logger.error(I18n.t('.no_cms.admin.menus.menus.destroy.error', title: @menu.name), true)
      end
      redirect_to action: :index
    end

    private

    def load_menu_item_templates
      NoCms::Menus.menu_kinds.each do |kind_name, _|
        @menu.menu_items.build kind: kind_name, no_cms_admin_template: true
      end
    end

    def load_menus
      @menus =  NoCms::Menus::Menu.all
    end

    def load_menu
      @menu = NoCms::Menus::Menu.find(params[:id])
    end

    def load_menu_section
      @current_section = 'menus'
    end

    def menu_params
      menu_params = params.require(:menu).permit(
        :name,
        :uid,
      )

      menu_params.merge!(menu_items_attributes: params[:menu][:menu_items_attributes]) unless params[:menu][:menu_items_attributes].blank?
      menu_params
    end

  end
end
