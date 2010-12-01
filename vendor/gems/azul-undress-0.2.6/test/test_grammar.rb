require File.expand_path(File.dirname(__FILE__) + "/test_helper")

module Undress
  class TestGrammar < Test::Unit::TestCase
    class Parent < Grammar
      rule_for(:p) {|e| "<this is a paragraph>#{content_of(e)}</this is a paragraph>" }
    end

    class WithPreProcessingRules < Parent
      pre_processing("p.foo") {|e| e.swap("<div>Cuack</div>") }
      rule_for(:div) {|e| "<this was a div>#{content_of(e)}</this was a div>" }
    end

    class Child < Parent; end

    class OverWriter < WithPreProcessingRules
      rule_for(:div) {|e| content_of(e) }
    end

    class TextileExtension < Textile
      rule_for(:a) {|e| "" }
    end

    def parse_with(grammar, html)
      grammar.process!(Nokogiri::HTML(html) % 'body')
    end

    context "extending a grammar" do
      test "the extended grammar should inherit the rules of the parent" do
        output = parse_with Child, "<p>Foo Bar</p>"
        assert_equal "<this is a paragraph>Foo Bar</this is a paragraph>", output
      end

      test "extending a grammar doesn't overwrite the parent's rules" do
        output = parse_with OverWriter, "<div>Foo</div>"
        assert_equal "Foo", output

        output = parse_with WithPreProcessingRules, "<div>Foo</div>"
        assert_equal "<this was a div>Foo</this was a div>", output
      end

      test "extending textile doesn't blow up" do
        output = parse_with TextileExtension, "<p><a href='/'>Cuack</a></p><p>Foo Bar</p><p>I <a href='/'>work</a></p>"
        assert_equal "Foo Bar\n\nI\n", output
      end
    end

    context "pre processing rules" do
      test "mutate the DOM before parsing the tags" do
        output = parse_with WithPreProcessingRules, "<p class='foo'>Blah</p><p>O hai</p>"
        assert_equal "<this was a div>Cuack</this was a div><this is a paragraph>O hai</this is a paragraph>", output
      end
    end

    class G1 < Undress::Grammar
    end

    class G2 < Undress::Grammar
      post_processing '!!!', ""
    end

    context "incapsulation" do
      test "icolates post_processing_rules" do
        o1 = parse_with G1, "<p>!!!</p>"
        assert_equal '<p>!!!</p>', o1
        o2 = parse_with G2, '!!!'
        assert_equal '<p></p>', o2
        assert_not_equal G1.post_processing_rules['!!!'], '!!!'
      end
    end
  end
end
