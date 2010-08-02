class DigitalgazetteToVersion1AndModerationToVersion8AndPublicHomeToVersion1AndTranslatorToVersion6 < ActiveRecord::Migration
  def self.up
    Engines.plugins["public_home"].migrate(1)
    Engines.plugins["digitalgazette"].migrate(1)
    Engines.plugins["moderation"].migrate(8)
    Engines.plugins["translator"].migrate(6)
  end

  def self.down
    Engines.plugins["digitalgazette"].migrate(0)
    Engines.plugins["moderation"].migrate(0)
    Engines.plugins["public_home"].migrate(0)
    Engines.plugins["translator"].migrate(0)
  end
end
