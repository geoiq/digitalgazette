class CreateSurveyTables < ActiveRecord::Migration
  def self.up
    create_table :surveys, :force => true  do |t|
      t.text :description
      t.datetime :created_at
      t.integer :responses_count, :default => 0
    end

    create_table :survey_questions, :force => true  do |t|
      t.string :type # STI
      t.text :choices
      t.integer :survey_id
      t.integer :position
      t.string :label
      t.text :details
      t.boolean :required
      t.datetime :created_at
      t.datetime :expires_at

      t.string :regex
      t.integer :maximum
      t.integer :minimum
    end

    create_table :survey_responses, :force => true  do |t|
      t.integer :survey_id
      t.integer :user_id
      t.string :name
      t.string :email
      t.integer :stars_count, :default => 0
      t.datetime :created_at
    end

    create_table :survey_answers, :force => true  do |t|
      t.integer :question_id
      t.integer :response_id
      t.integer :asset_id
      t.text :value
      t.string :type #STI
      t.datetime :created_at
    end
  end

  def self.down

  end
end
