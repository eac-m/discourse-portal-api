# name: discourse-portal-api
# about: API endpoint for EACM portal integration
# version: 0.1
# authors: EACM
# url: https://github.com/eac-m/discourse-portal-api
enabled_site_setting :baseline_latest_enabled
after_initialize do
  require_dependency 'application_controller'
  
  class ::BaselineLatestController < ::ApplicationController
    skip_before_action :check_xhr, :verify_authenticity_token, :redirect_to_login_if_required
    
    def latest
      # Check API key
      api_key = request.headers['Api-Key']
      
      if api_key.blank?
        render json: { error: 'API key required' }, status: 401
        return
      end
      
      api_key_record = ApiKey.with_key(api_key).first
      
      if api_key_record.nil?
        render json: { error: 'Invalid API key' }, status: 401
        return
      end
      
      # Use the API user's permissions
      api_user = api_key_record.user
      guardian = Guardian.new(api_user)
      
      # Get the limit parameter
      requested_limit = params[:limit]&.to_i || 20
      requested_limit = [requested_limit, 100].min  # Cap at 100
      
      topic_list = TopicQuery.new(api_user, {
        guardian: guardian,
        per_page: requested_limit
      }).list_latest
      
      # Ensure we only return the requested number
      topics = topic_list.topics.take(requested_limit).map do |t|
        {
          id: t.id,
          title: t.title,
          slug: t.slug,
          posts_count: t.posts_count,
          created_at: t.created_at,
          last_posted_at: t.last_posted_at,
          category_name: t.category&.name,
          tags: t.tags.pluck(:name),
          url: "#{Discourse.base_url}/t/#{t.slug}/#{t.id}",
          like_count: t.like_count,
          views: t.views,
          reply_count: t.reply_count
        }
      end
      
      render json: { 
        topics: topics,
        count: topics.length
      }
    end
  end
  
  Discourse::Application.routes.append do
    get '/baseline_latest' => 'baseline_latest#latest'
  end
end
