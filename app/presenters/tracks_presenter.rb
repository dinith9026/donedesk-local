class TracksPresenter < CollectionPresenter
  def size
    @collection.size
  end

  def presets
    context.presets
  end

  def active
    select { |track| track.active? }
  end

  def deactivated
    select { |track| track.deactivated? }
  end

  def new_path
    new_track_path
  end
end
