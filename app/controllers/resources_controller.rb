class ResourcesController < ApplicationController
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  before_action :check_if_signed_in

    def index
      if params[:import_note].present?
        @import_note=params[:import_note]
      else
        @import_note=""
      end
      if (params[:term].present?)
        @tmp = Resource.order(:name).where("name like ?","'%"+params[:term]+"%'")
        @resources=@tmp
        get_all_json
        render json: @resources.map(&:name)
      elsif (params[:q].present?)
        @tmp=Resource.order(:name).where("lower(name) like lower('%"+params[:q]+"%') or lower(description) like lower('%"+params[:q]+"%') or lower(url_preview) like lower('%"+params[:q]+"%')")
        @total_count=@tmp.count
        @pagy, @resources = pagy(@tmp, items: 10)
        get_all_json
      else
          @tmp=Resource.all.order(Arel.sql("created_at DESC"))
          @total_count=@tmp.count
          @pagy, @resources = pagy(@tmp, items: 10)
          get_all_json
      end
    end

    def show
    end

    def new
      @resource = current_user.resources.build
      @ref=""
      if (params[:ref].present?)
        @ref=params[:ref]
      end
    end

    def create
      @import_note=""
      if (params[:resources_json].present?)
        massport
      elsif (!params[:resource].nil? && (params[:resource][:url] || params[:resource][:file]))
        if (!params[:resource][:name])
          if (params[:resource][:file].present?)
            myfile=params[:resource][:file]
            file_contents=myfile.read
          else
            myfile=params[:resource][:url]
            require 'open-uri'
            begin
              file_contents= URI.open(myfile) {|f| f.read }
            rescue
              file_contents=""
            end
          end
          if (!file_contents.nil?)
           if (file_contents.length>0)
              resource_list = JSON.parse(file_contents)
              resource_list.each do |resrc|
                tmp = Resource.where(name: resrc['name']).first
                if (!tmp.nil?)
                  if (params[:resource][:overwrite]=="1")
                      tmp.destroy
                      if (params[:resource][:used_for_qs]!="1")
                        resrc['used_for_qs']=''
                        @resource = current_user.resources.build(resrc)
                      end
                      @resource = current_user.resources.build(resrc)
                      if @resource.save
                        @import_note=@import_note+resrc['name']+t('rsrc_imported')+"<br>"
                      end
                  else
                    @import_note=@import_note+resrc['name']+t('rsrc_imported')+"<br>"
                  end
                else
                    @resource = current_user.resources.build(resrc)
                    if @resource.save
                      @import_note=@import_note+resrc['name']+t('rsrc_imported_successfully')+"<br>"
                    end
                end
            end
            render 'show'
           end
          end
        else
          @resource = current_user.resources.build(resource_params)
          if @resource.save
              redirect_to resources_path
          else
              render 'new'
          end
        end
      else
        return
      end
    end

    def edit
      if current_user.id!=@resource.user_id and current_user.role!="admin"
        redirect_to resource_path(@resource)
      end
    end

    def update
      if current_user.id!=@resource.user_id and current_user.role!="admin"
        redirect_to resource_path(@resource)
        return
      end
      if @resource.update(resource_params)
        redirect_to resource_path(@resource)
      else
        render 'edit'
      end
    end

    def destroy
      @resource.destroy
      redirect_to resources_path
    end

    def export
        if (!params[:id].blank?)
          resrc=Resource.find(params[:id])
        end
        result_json=[]
        res_json = {
          "name" => resrc.name,
          "description" => resrc.description,
          "tutorial" => resrc.tutorial,
          "icon" => resrc.icon,
          "url" => resrc.url,
          "used_for_qs" => resrc.used_for_qs
        }
        result_json << res_json
        send_data result_json.to_json,
          :type => 'text/json; charset=UTF-8;',
          :disposition => "attachment; filename="+resrc.name+".json"
    end

    private

    def massport
      resources_json=params[:resources_json]
      send_data resources_json,
        :type => 'text/json; charset=UTF-8;',
        :disposition => "attachment; filename=resources.json"
    end

    def get_all_json
      @resources_json = []
      @tmp.all.each do |resrc|
        res_json = {
          "name" => resrc.name,
          "description" => resrc.description,
          "tutorial" => resrc.tutorial,
          "icon" => resrc.icon,
          "url" => resrc.url,
          "url_preview" => resrc.url_preview,
          "used_for_qs" => resrc.used_for_qs
        }
        @resources_json << res_json
      end
      @resources_json = @resources_json.to_json
      @resources_json=@resources_json.to_s;
    end

      def resource_params
        if (!params[:resources_json].present?)
          params.require(:resource).permit(:name, :url, :description, :tutorial, :icon, :used_for_qs, :ref, :url_preview)
        end
      end

      def find_resource
        @resource = Resource.find(params[:id])
      end

end
