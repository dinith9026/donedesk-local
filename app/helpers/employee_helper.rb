module EmployeeHelper
  def employee_status_badge(status)
    tag_type = { 'terminated' => 'tag-danger',
                 'suspended'  => 'tag-warning',
                 'employed'   => 'tag-success',
               }.fetch(status, 'tag-grey')

    content_tag(:span, class: "tag tag-default #{tag_type} font-small-1 valign-middle") do
      status.downcase
    end
  end
end
