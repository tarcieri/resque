Resque::Server.helpers do
  ####################
  #failed.erb helpers#
  ####################

  def failed_queue_focus
    if params[:class]
      "'#{params[:class]}'"
    elsif params[:queue]
      "'#{params[:queue]}'"
    else ''
    end
  end

  def failed_queue_clear_label
    "Clear #{failed_queue_focus} Jobs"
  end

  def failed_queue_requeue_label
    "Retry #{failed_queue_focus} Jobs"
  end

  def failed_queue_clear_path
    path = "failed#{'/' + params[:queue] if params[:queue]}/clear"
    path << "?class=#{params[:class]}" if params[:class]
    u path
  end

  def failed_queue_requeue_path
    path = "failed#{'/' + params[:queue] if params[:queue]}/requeue/all"
    path << "?class=#{params[:class]}" if params[:class]
    u path
  end

  def failed_date_format
    "%Y/%m/%d %T %z"
  end

  def failed_multiple_queues?
    return @multiple_failed_queues if defined?(@multiple_failed_queues)
    @multiple_failed_queues = Resque::Failure.queues.size > 1
  end

  def failed_size
    @failed_size ||= Resque::Failure.count(params[:queue], params[:class])
  end

  def failed_per_page
    @failed_per_page = if params[:class]
      failed_size  
    else
      20
    end
  end

  def failed_start_at
    params[:start].to_i
  end

  def failed_end_at
    if failed_start_at + failed_per_page > failed_size
      failed_size
    else
      failed_start_at + failed_per_page
    end
  end

  def failed_class_counts(queue = params[:queue])
    classes = Hash.new(0)
    Resque::Failure.each(0, Resque::Failure.count(queue), queue) do |_, item|
      class_name = item['payload']['class'] if item['payload']
      class_name ||= "nil"
      classes[class_name] += 1
    end
    classes
  end
end