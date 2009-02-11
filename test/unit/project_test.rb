require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  fixtures :projects

  def test_truth
    assert true
  end

  def test_presence_of
    project = Project.new
    assert !project.valid?

    project.name = "test"
    assert project.valid?
  end

  def test_validate_uniqueness_of_name
    project = Project.new(:name => projects(:test_project).name,
                          :created_at => Time.now,
                          :user_id => projects(:test_project).user_id,
                          :id => 999
                          )
    assert( !project.save )
  end
end
