module ApplicationHelper
  include Pagy::Frontend

  def try_resource(resource_name, type)
    results=""
    name_field=""
    domain_name=""
    if (type=="medium") then obj=@medium; elsif (type=="src") then obj=@src; else obj=@claim; end
    if type=="claim" then name_field=obj.title else name_field=obj.name; end
    if (type=="src") then type="source"; end
    if (obj.present?)
      if (obj.url.present?)
        begin
          domain_name=URI.parse(obj.url).host
          domain_name=domain_name.sub(/^www\./, '')
        rescue
          domain_name=obj.url
        end
      end
    end
    name=resource_name.downcase
    resource = Resource.where("name=?",resource_name).first
    if (!resource.url.present?)
        resource.url=''
    end

##################################################

#Image-related resources

#Google t('reverse_image_search')
    if resource.url.include? "google.com" and name.include? "image"
      if domain_name
        if !obj.url_preview.nil?
          img=obj.url_preview.scan(/img src=\\"([^<>]*?)\\"/).first
          if !img.nil?
            img=img[0]
            results="<strong><a href='https://www.google.com/searchbyimage?image_url="+img.to_s+"' target=_blank>"+t('reverse_image_search')+"</a></strong>"+t('using')
          else
            results="<strong><a href='https://www.google.com/searchbyimage?image_url="+obj.url+"' target=_blank>"+t('reverse_image_search')+"</a></strong>"+t('using')
          end
        end
      end
    end

    if resource.url.include? "yandex.com"
      if domain_name
        if !obj.url_preview.nil?
          img=obj.url_preview.scan(/img src=\\"([^<>]*?)\\"/).first
          if !img.nil?
            img=img[0]
            results="<strong><a href='https://yandex.com/images/search?source=collections&url="+img.to_s+"&rpt=imageview' target=_blank>"+t('reverse_image_search')+"</a></strong>"+t('using')
          else
            results="<strong><a href='https://yandex.com/images/search?source=collections&url="+obj.url+"&rpt=imageview' target=_blank>"+t('reverse_image_search')+"</a></strong>"+t('using')
          end
        end
      end
    end

    if resource.url.include? "tineye.com"
      if domain_name
        if !obj.url_preview.nil?
          img=obj.url_preview.scan(/img src=\\"([^<>]*?)\\"/).first
          if !img.nil?
            img=img[0]
            results="<strong><a href='https://tineye.com/search?url="+img.to_s+"' target=_blank>"+t('reverse_image_search')+"</a></strong>"+t('using')
          else
            results="<strong><a href='https://tineye.com/search?url="+obj.url+"&rpt=imageview' target=_blank>"+t('reverse_image_search')+"</a></strong>"+t('using')
          end
        end
      end
    end

#META DATA (EXIF) data extractor

if resource.url.include? "metapicz.com"
    if !obj.url_preview.nil?
      img=obj.url_preview.scan(/img src=\\"([^<>]*?)\\"/).first
      if !img.nil?
        img=img[0]
        results="<strong><a href='http://metapicz.com/#landing?imgsrc="+img.to_s+"' target=_blank>"+t('view_metadata')+"</a></strong>"+t('using')
      else
        results="<strong><a href='http://metapicz.com/#landing?imgsrc="+obj.url+"' target=_blank>"+t('view_metadata')+"</a></strong>"+t('using')
      end
    end
end

##################################################

#video-related resources

#### Inteltechniques video reverse search
if resource.url.include? "inteltechniques.com"
  results="<strong><a href='https://inteltechniques.com/menu/pages/reverse.video.tool.html' target=_blank>"+t('reverse_video_search')+"</a></strong>"+t('using')
end

#WatchFrameByFrame
    if resource.url.include? "watchframebyframe.com"
      if domain_name
        if (obj.url.include? "youtube.com" or obj.url.include? "youtu.be" or obj.url.include? "vimeo.com")
          results="<strong><a href='http://www.watchframebyframe.com/search?search="+obj.url+"' target=_blank>"+t('open_video')+"</a></strong>"+t('using')
        end
      end
    end

#WatchFrameByFrame
    if name.include? "invid"
      results="<strong><a href='https://chrome.google.com/webstore/detail/mhccpoafgdgbhnjfhkcmgknndkeenfhe' target=_blank>"+t('download')+"</a>"+t('use_plugin')+"</a></strong>"+t('using')
    end

##################################################

#content-related and general resources
##################################################

###### Google search for fact-checked stories
    if resource.url.include? "google.com" and name.include? "search" and not name.include? "image"

      if (obj.present?)
        results="<strong><a href='https://www.google.com/search?q="+name_field+"' target=_blank>"+t('search_it')+"</a></strong>"
        if (!obj.url_preview.blank?)
            if (obj.url_preview.include? "<p")
              description=obj.url_preview.match(/<p[^>]+?>([^<]+)/)[1]
              if (!description.blank?)
                results=results+" - <strong><a href='https://www.google.com/search?q="+description.gsub('\\"', '"')+"' target=_blank>"+t('search_desc')+"</a></strong>"
              end
            end
        end
        results=results+t('using')
     end
    end

#### List of fake websites on wikipedia and factcheck.org (<%== t('using') %> Google search)
    if (resource.url.include? "wikipedia.org" or name.include? "factcheck.org") and name.include? "list"
      if (!domain_name.blank?)
        results="<strong><a href='https://www.google.com/search?q="+domain_name+"+site%3A"+resource.url+"' target=_blank>"+t('check_blacklisted',type: t('the_'+type))+"</a></strong>"+t('using')
      else
        results="<strong><a href='https://www.google.com/search?q="+name_field+"+site%3A"+resource.url+"' target=_blank>"+t('check_blacklisted',type: t('the_'+type))+"</a></strong>"+t('using')
      end
    end

###### Media Bias Fact Check
    if resource.url.include? "mediabiasfactcheck.com"
      results="<strong><a href='https://mediabiasfactcheck.com/?s="+name_field+"' target=_blank>"+t('check_rating', type: t('the_'+type))+"</a></strong>"
      if (!domain_name.blank?)
        results=results+" or its <strong><a href='https://mediabiasfactcheck.com/?s="+domain_name+"' target=_blank>URL</a></strong>"
      end
      results=results+t('using')
    end

#####Related Fact Checks
    if resource.url.include? "relatedfactchecks.org"
      if (!domain_name.blank?)
          results="<strong><a href='https://relatedfactchecks.org/search?url="+obj.url+"' target=_blank>"+t('check_factchecked')+"</a></strong>"+t('using')
      end
    end

#####Web of Trust
    if resource.url.include? "mywot.com"
      if (!domain_name.blank?)
          results="<strong><a href='https://www.mywot.com/en/scorecard/"+domain_name+"' target=_blank>"+t('check_reputation')+"</a></strong>"+t('using')
      end
    end

#### ViewDNS
    if resource.url.include? "viewdns.info"
      if (!domain_name.blank?)
          results="<strong><a href='https://viewdns.info/whois/?domain="+domain_name+"' target=_blank>"+t('check_whois')+"</a></strong>"+t('using')
      end
    end

##### Alexa website ranking
    if resource.url.include? "alexa.com"
      if (!domain_name.blank?)
          results="<strong><a href='https://www.alexa.com/siteinfo/"+domain_name+"' target=_blank>"+t('check_domain_ranking')+"</a></strong>"+t('using')
      end
    end

#### SimilarWeb
    if resource.url.include? "similarweb.com" or name.include? "similar web"
      if (!domain_name.blank?)
          results="<strong><a href='https://www.similarweb.com/website/"+domain_name+"' target=_blank>"+t('info_on_domain')+"</a></strong>"+t('using')
      end
    end

#### Pipl
    if resource.url.include? "pipl.com"
      results="<strong><a href='https://pipl.com/search/?q="+name_field+"' target=_blank>"+t('learn_more',type: t('the_'+type))+"</a></strong>"+t('using')
    end

#### Inteltechniques person search
    if resource.url.include? "inteltechniques.com"
      results="<strong><a href='https://inteltechniques.com/menu/pages/person.tool.html' target=_blank>"+t('research_source')+"</a></strong>"+t('using')
    end

##### Twitter search
    if resource.url.include? "twitter.com"
      results="<strong><a href='https://twitter.com/search?l=&q=%22"+name_field+"%22&src=typd&lang=en' target=_blank>"+t('search_it')+"</a></strong>"+t('using')
    end

####### Real or Satire
    if resource.url.include? "realorsatire.com"
      if (!domain_name.blank?)
          results="<strong><a href='https://realorsatire.com/?s="+domain_name+"' target=_blank>"+t('check_if_satire',type: t('the_'+type))+"</a></strong>"+t('using')
      end
    end

####### Assessing stories with unnamed sources
    if name.include? "assess" and name.include? "unnamed sources"
      results="<strong><a href='"+resource.url+"' target=_blank>"+t('read_tips')+"</a></strong> "+t('using')
    end

####### Detecting clickbait titles
    if name.include? "clickbait" and name.include? "title"
      results="<strong><a href='"+resource.url+"' target=_blank>"+t('read_tips')+"</a></strong>  "+t('using')

    end

#######################################################################
    return results
  end

end
