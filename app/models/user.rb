class User < ApplicationRecord
  has_many :created_polls, class_name: :Poll, foreign_key: :creator_id
  has_many :votes
  has_many :chosen_answers, through: :votes, source: :answer
  has_many :squad_members, class_name: :Friendship, foreign_key: :adder_id
  has_many :squad_memberships, class_name: :Friendship, foreign_key: :accepter_id
  has_many :squad_membership_users, through: :squad_memberships, source: :adder

  before_create do
    self.invite_code = SecureRandom.hex(4);
  end

  has_secure_password

  def sorted_created_current_polls
    my_polls = self.created_polls.select { |poll| poll.current? }
    my_polls.sort_by { |poll| poll.created_at }.reverse
  end

  def polls_to_answer
    polls_to_answer = []

    self.squad_membership_users.each do |user|
      user.created_polls.each do |poll|
        if poll.current?
          polls_to_answer << poll
        end
      end
    end
    return polls_to_answer - self.taken_polls
  end

  def sorted_created_old_polls
    my_polls = self.created_polls.select { |poll| poll.current? == false }
    my_polls.sort_by { |poll| poll.created_at }.reverse
  end

  def taken_polls
    self.chosen_answers.map { |answer| answer.poll }
  end

  def recent_taken_polls
    self.taken_polls.select { |poll| poll.created_at > 1.day.ago}
  end
end
