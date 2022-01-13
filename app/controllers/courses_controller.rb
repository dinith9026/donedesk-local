class CoursesController < ApplicationController
  def index
    authorize Course
    courses =
      current_account
      .courses
      .includes(:account)
      .page(params[:page])
      .per(10)

    if params[:search]
      courses = courses.where("title ILIKE ?", "%#{params[:search]}%")
    else
      if params[:status] == 'my courses'
        courses = courses.custom(current_account)
      elsif params[:status] == 'other courses'
        courses = courses.canned
      end
    end

    @courses_presenter = CoursesPresenter.new(courses, current_user)
  end

  def new
    authorize Course
    @form = CourseForm.new.with_policy(policy(Course.new))
  end

  def create
    course = Course.new
    authorize course
    @form = CourseForm.from_params(course_params).with_policy(policy(course))

    CreateCourse.call(current_account, @form) do
      on(:ok)      { |course| set_flash_success_and_redirect_to(course) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  def show
    course = find_course!
    authorize course
    @course_presenter = CoursePresenter.new(course, policy(course))
  end

  def edit
    course = find_course!
    authorize course
    @form = CourseForm
              .from_model(course)
              .with_policy(policy(course))
  end

  def update
    course = find_course!
    authorize course
    @form = CourseForm
              .from_model(course)
              .with_policy(policy(course))
    @form.attributes = course_params.to_h

    UpdateCourse.call(@form, course, current_account) do
      on(:ok)      { |course| set_flash_success_and_redirect_to(course) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def create_assignments
    course = find_course!
    authorize course, :assign?
    @form = AssignCourseToEmployeesForm.new(assignment_params.to_h)
    @form.course = course

    AssignCourseToEmployees.call(course, @form) do
      on(:ok) { set_flash_success_and_redirect_to(course) }
      on(:invalid) { |course, error| set_flash_error_and_redirect_to(course, error) }
    end
  end

  def deactivate
    course = find_course!
    authorize course

    DeactivateCourse.call(course) do
      on(:ok) { set_flash_success_and_redirect_to(courses_url) }
    end
  end

  def reactivate
    course = find_course!
    authorize course

    ReactivateCourse.call(course) do
      on(:ok) { |course| set_flash_success_and_redirect_to(course) }
    end
  end

  private

  def course_params
    params[:course][:states] ||= [] unless params[:course].has_key?(:states)
    params[:course][:supplements] ||= [] unless params[:course].has_key?(:supplements)
    params.require(:course).permit(
      :account_id, :title, :code, :description, :compliance_expiration_in_days, :days_due_within,
      :max_test_retakes, :passing_threshold_percentage, :material_s3_key, :is_canned, :certificate_type,
      states: [], supplements: []
    )
  end

  def assignment_params
    params.permit(employee_record_ids: [])
  end

  def find_course!
    current_account.find_course!(params[:id])
  end
end
