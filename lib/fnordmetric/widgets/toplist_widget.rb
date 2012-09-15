class FnordMetric::ToplistWidget < FnordMetric::Widget

  def self.execute(namespace, event)
    t = Time.now.to_i

    return false unless event["gauge"]

    resp = if event["cmd"] == "values_for"
      {
        :cmd => :values_for,
        :gauge => event["gauge"],
        :values => execute_values_for(namespace.gauges[event["gauge"].to_sym], t),
        :count  => namespace.gauges[event["gauge"].to_sym].field_values_total(t)
      }
    end

    return false unless resp

    resp.merge(
      :class => "widget_response",
      :widget_key => event["widget_key"]
    )
  end

  def self.execute_values_for(gauge, time)
    gauge.field_values_at(time).sort do |a,b|
      a.first.to_i <=> b.first.to_i
    end.map do |a|
      [a.first, a.second.to_i]
    end
  end

  def data
    super.merge(
      :gauges => data_gauges,
      :autoupdate => (@opts[:autoupdate] || 0),
      :render_target => @opts[:render_target],
      :ticks => @opts[:ticks],
      :click_callback => @opts[:click_callback],
      :async_chart => true,
      :tick => tick
    ).tap do |dat|
      dat.merge!(
        :gauges => @opts[:_gauges]
      ) if dat[:ticks]
    end
  end

  def data_gauges
    Hash.new.tap do |hash|
      gauges.each do |g|
        hash[g.name] = {
          :tick => g.tick,
          :title => g.title
        }
      end
    end
  end

  def has_tick?
    false
  end

end
