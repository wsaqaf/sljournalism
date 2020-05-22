class ApplicationController < ActionController::Base
    include Pagy::Backend
    include Pundit
    acts_as_token_authentication_handler_for User, fallback: :none

    before_action :set_locale

    def get_preview(url)
      @filter_msg=""
      output=""
      preview = Thumbnail.new(params[:url])
      imglist=""
      titl=""
      desc=""
      if !preview.blank?
        if !preview.title.nil? and !preview.description.nil?
          i=0
          titl=preview.title
          desc=preview.description
          imglist="var images= ["
          preview.images.each do |img|
            imglist=imglist+"'"+img.src.to_s+"',"
            i=i+1
          end
          if i>1
            imglist="<script>\nvar i=0;\n"+imglist.chomp(',')+"];\n"
            imglist=imglist+"prev.onclick=function(){if(i==0){i="+i.to_s+";};document.getElementById('cimg').src=images[--i];}</script>"
            output=output+"\n"+imglist
            output=output+'<br><a href="#" id="prev">Change thumbnail</a><br><div id="final_url_preview" class="fragment">'
            output=output+'<div style="text-align: left"><img src="'+preview.images.first.src.to_s+'" id="cimg" style="max-width:128px;max-height:75px" />'
          elsif i==1
            output=output+'<br><div id="final_url_preview" class="fragment"><div style="text-align: left"><img src="'+preview.images.first.src.to_s+'" id="cimg" style="max-width:128px;max-height:75px" /><br>'
          elsif is_img(params[:url])
            output=output+'<div id="final_url_preview" class="fragment"><div style="text-align: left"><img src="'+params[:url]+'" id="cimg" style="max-width:128px;max-height:75px" /><br>'
            titl=params[:url]
            desc="URL"
          else
            output=output+'<br><div id="final_url_preview" class="fragment"><div style="text-align: left">'
          end
          url=params[:url]
          if (url.present?)
              begin
                domain_name=URI.parse(url).host
                domain_name=domain_name.sub(/^www\./, '')
              rescue
                domain_name=url
              end
          end
          output=output+"\n<h4><a href=\""+params[:url]+"\" target=_blank>"+titl+"</a></h4><br><i>"+domain_name.to_s+"</i><br><p class=\"text\">"+desc+"</p></div></div>"
        end
      end
      return output
    end
    
    private

    def set_locale
       I18n.default_locale = params[:locale] if params[:locale].present?
       @pagy_locale = params[:locale] || 'en'
       @no_turbolinks="false"
    end

#    protect_from_forgery with: :exception

    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :set_current_user

    autocomplete :user, :affiliation

    def set_current_user
      User.current_user = current_user
    end

    def current_account
      @current_account ||= User.find(params[:user_id])
    end

    private def payload
      JWT.decode(get_token, Rails.application.secrets.secret_key_base, true, { algorithm: 'HS256'}).first
    end

    private def get_token
      request.headers['Authorization'].split(' ').last
    end

    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :affiliation, :role, :url, :details, :email, :password])
        devise_parameter_sanitizer.permit(:account_update, keys: [:name, :affiliation, :role, :url, :details, :email, :password, :current_password])
    end

    def check_if_signed_in
      if !user_signed_in?
        redirect_to new_user_session_path
        return
      end
    end

      def filter_bar(page,filter_option)
        f={"a"=>"","m"=>"","r"=>"","u"=>"","n"=>""}
        page1=page.downcase
        page2=page
        if (page=="Srcs") then page2="Sources"; end
        f.each do |key, value|
            if key==filter_option then f[key]="selected"; end
        end
        return "<div class='form-group'>
        <label for=''>Filter</label><select class='form-control' id='filter'><option value='"+page1+"' "+f['a']+">"+t(page2.downcase)+"</option><option value='?filter=r' "+f['r']+">"+t(page2.downcase)+t('been_reviewed')+"</option><option value='?filter=n' "+f['n']+">"+t(page2.downcase)+t('with_no_reviews')+"</option><option value='?filter=m' "+f['m']+">"+t(page2.downcase)+t('you_created')+"</option><option value='?filter=u' "+f['u']+">"+t(page2.downcase)+t('you_reviewed')+"</option></select></div>\n<script>$(function(){$('#filter').on('change',function(){{window.location=$(this).val();}return false;});});</script>"
      end

      def sort_statement(page,sorting)
        if page=="claim"
           page2=""
        else
          page2=page+"_"
        end

        case sorting
        when "r"
          return "count("+page+"_reviews."+page2+"review_verdict) DESC"
        when "rp"
          return "sum("+page+"_reviews."+page2+"review_verdict-2) DESC"
        when "rn"
          return "sum("+page+"_reviews."+page2+"review_verdict-2) ASC"
        when "rt"
          return page+"_reviews.updated_at DESC,"+page+"_reviews.created_at DESC"
        end
      end

      def sort_bar(page,sort_option)
        s={"td"=>"","r"=>"","rt"=>"","rp"=>"","rn"=>""}
        s.each do |key, value|
            if key==sort_option then s[key]="selected"; end
        end
        return "<div class='form-group'>
        <label for=''>Sort by</label><select class='form-control' id='sort'><option value='?sort=td' "+s['td']+">"+t('sort_by_time')+"</option><option value='?sort=rt' "+s['rt']+">"+t('sort_by_review_time')+"</option><option value='?sort=r' "+s['r']+">"+t('sort_by_reviews')+"</option><option value='?sort=rp' "+s['rp']+">"+t('sort_by_pos_reviews')+"</option><option value='?sort=rn' "+s['rn']+">"+t('sort_by_neg_reviews')+
        "</option><select></div>\n<script>$(function(){$('#sort').on('change',function(){{window.location=$(this).val();}return false;});});</script>"
      end

    def linkpreview
        url = params[:url]
        preview = LinkPreviewParser.parse(url) # returns a Hash
        respond_to do |format|
            format.json { render :json => preview }
        end
    end

    class Thumbnail
      require 'link_thumbnailer'
      attr_reader :url
      def initialize(url)
        @url = url
      end
      def title
        thumbnailer.try(:title)
      end
      def description
        thumbnailer.try(:description)
      end
      def images
        thumbnailer.try(:images)
      end
      def videos
        thumbnailer.try(:images)
      end
      def favicon
        thumbnailer.try(:favicon)
      end

      private
      def thumbnailer
        @thumbnailer ||= LinkThumbnailer.generate(url, verify_ssl: false)
      rescue LinkThumbnailer::Exceptions
        nil
      end
    end

end
