module Search
  class IndexToElasticsearchWorker
    include Sidekiq::Worker

    sidekiq_options queue: :high_priority, lock: :until_executing

    def perform(object_class, id)
      # PodcastEpisodes and Articles share an index so their IDs are prepended with their class names
      # article_ID and podcast_episode_ID
      object_int_id = id.is_a?(Integer) ? id : id.split("_").last.to_i
      object = object_class.constantize.find(object_int_id)
      object.index_to_elasticsearch_inline
    rescue ActiveRecord::RecordNotFound => e
      return if object_class == "Reaction"

      raise e
    end
  end
end
