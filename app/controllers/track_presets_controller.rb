class TrackPresetsController < ApplicationController
  def index
    authorize TrackPreset
    @track_presets = TrackPreset.all
  end

  def new
    authorize TrackPreset
    @courses = get_courses
    @track_preset = TrackPreset.new
  end

  def create
    authorize TrackPreset
    @track_preset = TrackPreset.new(track_preset_params)

    if @track_preset.save
      set_flash_success_and_redirect_to(track_preset_path(@track_preset))
    else
      @courses = get_courses
      render :new
    end
  end

  def show
    @track_preset = TrackPreset.find(params[:id])
    authorize @track_preset
    @course_titles = Course.where(id: @track_preset.courses).map do |course|
      { course.id => course.title }
    end.inject(:merge)
  end

  def edit
    @track_preset = TrackPreset.find(params[:id])
    @courses = get_courses
    authorize @track_preset
  end

  def update
    @track_preset = TrackPreset.find(params[:id])
    authorize @track_preset

    if @track_preset.update(track_preset_params)
      set_flash_success_and_redirect_to(track_preset_path(@track_preset))
    else
      @courses = get_courses
      render :edit
    end
  end

  def copy
    track_preset = TrackPreset.find(params[:id])
    authorize track_preset

    course_ids =
      Course
      .where(id: track_preset.courses)
      .active
      .pluck(:id)
      .sort_by { |e| track_preset.courses.index(e) || Float::INFINITY }

    track = current_account.tracks.build(
      name: track_preset.name,
      account_id: current_account.id,
      course_ids: course_ids
    )

    if track.save
      set_flash_success_and_redirect_to(track_path(track))
    else
      error = "Looks like you already have a track with the name: " \
              "`#{track_preset.name}`. Rename or delete it first, " \
              "then try adding the preset again."
      set_flash_error_and_redirect_to(tracks_path, error)
    end
  end

  def reorder_courses
    @track_preset = TrackPreset.find(params[:id])
    authorize @track_preset

    position = params[:position].to_i - 1
    course_id = params[:course_id]
    courses = @track_preset.courses

    current_index = @track_preset.courses.find_index(course_id)
    @track_preset.courses = courses.insert(position, courses.delete_at(current_index))
    @track_preset.save!

    head :no_content
  end

  def destroy
    @track_preset = TrackPreset.find(params[:id])
    authorize @track_preset

    @track_preset.destroy!

    set_flash_success_and_redirect_to(track_presets_path)
  end

  private

  def track_preset_params
    params.require(:track_preset).permit(:name, courses: [])
  end

  def get_courses
    Course.canned.active
  end
end
