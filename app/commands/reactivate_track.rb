class ReactivateTrack < ApplicationCommand
  def initialize(track)
    @track = track
  end

  def call
    @track.reactivate!
    broadcast(:ok, @track)
  end
end
