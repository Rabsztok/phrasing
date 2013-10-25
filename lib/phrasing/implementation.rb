module Phrasing
  module Implementation
    # this method overrides part of the i18n gem, lib/i18n/backend/simple.rb
    def lookup(locale, key, scope = [], options = {})
      return super unless ActiveRecord::Base.connected? && PhrasingPhrase.table_exists?

      scoped_key = I18n.normalize_keys(nil, key, scope, options[:separator]).join(".")

      cct = PhrasingPhrase.where(locale: locale.to_s, key: scoped_key).first
      return cct.value if cct

      value = super(locale, key, scope, options)
      if value.is_a?(String) || value.nil?
        phrasing_phrase = PhrasingPhrase.new
        phrasing_phrase.locale = locale.to_s, 
        phrasing_phrase.key = scoped_key
        phrasing_phrase.value = value
        phrasing_phrase.save
      end
      value
    end
  end
end
