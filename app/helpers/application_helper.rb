module ApplicationHelper
  # 文中の "\n" では必ず改行し、
  # 1行が入りきらないときは句読点（、。）の直後でだけ折り返す
  # block: true にすると、句読点ごとに必ず改行する（見出しの行数を揃えたいとき用）
  def phrase_wrap(text, block: false)
    lines = text.split("\n").map do |line|
      phrases = line.scan(/[^、。]+[、。」』）]*/)
      tag.span(safe_join(phrases.map { |phrase| tag.span(phrase, class: block ? "block" : "inline-block") }), class: "block")
    end
    safe_join(lines)
  end
end
