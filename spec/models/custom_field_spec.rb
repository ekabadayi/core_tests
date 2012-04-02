require File.expand_path(File.dirname(__FILE__) + "/../spec_helper.rb")

describe CustomField do
  let(:field) { Factory.build :custom_field }
  let(:field2) { Factory.build :custom_field }

  describe :name do
    describe "uniqueness" do

      describe "WHEN value, locale and type are identical" do
        before do
          field.name = field2.name = "taken name"
          field2.save!
        end

        it { field.should_not be_valid }
      end

      describe "WHEN value and locale are identical and type is different" do
        before do
          field.name = field2.name = "taken name"
          field2.save!
          field.type = "TestCustomField"
        end

        it { field.should be_valid }
      end

      describe "WHEN type and locale are identical and value is different" do
        before do
          field.name = "new name"
          field2.name = "taken name"
          field2.save!
        end

        it { field.should be_valid }
      end

      describe "WHEN value and type are identical and locale is different" do
        before do
          I18n.locale = :de
          field2.name = "taken_name"
          field2.save!
          I18n.locale = :en
          field.name = "taken_name"
        end

        it { field.should be_valid }
      end
    end

    describe "localization" do
      before do
        I18n.locale = :de
        field.name = "Feld"

        I18n.locale = :en
        field.name = "Field"
      end

      it "should return english name when in locale en" do
        I18n.locale = :en
        field.name.should == "Field"
      end

      it "should return german name when in locale de" do
        I18n.locale = :de
        field.name.should == "Feld"
      end
    end
  end

  describe :translation_attributes do
    before do
      field.translations_attributes = [ { "name" => "Feld", "default_value" => "zwei", "possible_values" => ["eins", "zwei", "drei"], "locale" => "de" },
                                        { "name" => "Field", "locale" => "en", "possible_values" => "one\ntwo\nthree\n" },
                                        { "name" => "", "default_value" => "", "locale" => "fr" },
                                        { "name" => "lorem", "locale" => ""},
                                        { "default_value" => "blubs", "locale" => "" },
                                        { "locale" => "es" } ]
      field.field_format = 'list'
      field.save!
      field.reload
    end

    it { field.name(:en).should == "Field" }
    it { field.name(:de).should == "Feld" }
    it { field.name(:fr).should == "" }
    it { field.default_value(:en).should == nil }
    it { field.default_value(:de).should == "zwei" }
    it { field.default_value(:fr).should == "" }
    it { field.possible_values(:de).should =~ ["eins", "zwei", "drei"] }
    it { field.possible_values(:en).should =~ ["one", "two", "three"] }
    it { field.should have(3).translations }
  end

  describe :default_value do
    describe "localization" do
      before do
        I18n.locale = :de
        field.default_value = "Standard"

        I18n.locale = :en
        field.default_value = "default"
      end

      it { field.default_value(:en).should == "default" }
      it { field.default_value(:de).should == "Standard" }
    end
  end

  describe :possible_values do
    describe "localization" do
      before do
        I18n.locale = :de
        field.possible_values = ["eins", "zwei", "drei"]

        I18n.locale = :en
        field.possible_values = ["one", "two", "three"]

        I18n.locale = :fr
        field.possible_values = "un\ndeux\ntrois"

        I18n.locale = :de
        field.save!
        field.reload
      end

      it { field.possible_values(:en).should == ["one", "two", "three"] }
      it { field.possible_values(:de).should == ["eins", "zwei", "drei"] }
      it { field.possible_values(:fr).should == ["un", "deux", "trois"] }
    end
  end

  describe :valid? do
    describe "WITH a list field
              WITH two translations
              WITH default_value not included in possible_values in the non current locale translation" do

      before do
        field.field_format = 'list'
        field.translations_attributes = [ { "name" => "Feld",
                                            "default_value" => "vier",
                                            "possible_values" => ["eins", "zwei", "drei"],
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "locale" => "en",
                                            "possible_values" => "one\ntwo\nthree\n",
                                            "default_value" => "two" } ]
      end

      it { field.should_not be_valid }
    end

    describe "WITH a list field
              WITH two translations
              WITH default_value included in possible_values" do

      before do
        field.field_format = 'list'
        field.translations_attributes = [ { "name" => "Feld",
                                            "default_value" => "zwei",
                                            "possible_values" => ["eins", "zwei", "drei"],
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "locale" => "en",
                                            "possible_values" => "one\ntwo\nthree\n",
                                            "default_value" => "two" } ]
      end

      it { field.should be_valid }
    end


    describe "WITH a list field
              WITH two translations
              WITH default_value not included in possible_values in the current locale translation" do

      before do
        field.field_format = 'list'
        field.translations_attributes = [ { "name" => "Feld",
                                            "default_value" => "zwei",
                                            "possible_values" => ["eins", "zwei", "drei"],
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "locale" => "en",
                                            "possible_values" => "one\ntwo\nthree\n",
                                            "default_value" => "four" } ]
      end

      it { field.should_not be_valid }
    end

    describe "WITH a list field
              WITH two translations
              WITH possible_values beeing empty in a fallbacked translation" do

      before do
        field.field_format = 'list'
        field.translations_attributes = [ { "name" => "Feld",
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "locale" => "en",
                                            "possible_values" => "one\ntwo\nthree\n",
                                            "default_value" => "two" } ]
      end

      it { field.should be_valid }
    end

    describe "WITH a list field
              WITH two translations
              WITH possible_values beeing empty in a non fallbacked translation" do

      before do
        field.field_format = 'list'
        field.translations_attributes = [ { "name" => "Feld",
                                            "default_value" => "zwei",
                                            "possible_values" => "eins\nzwei\ndrei",
                                            "locale" => "de" },
                                          { "name" => "Field",
                                            "locale" => "en" } ]
      end

      it { field.should_not be_valid }
    end
  end
end
