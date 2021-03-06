% Colorized Autotest with Rspec
% 2008-04-17

I had problems with getting the `autotest/redgreen` bundled with
[ZenTest](http://zenspider.com/ZSS/Products/ZenTest/) to work
when using [RSpec](http://rspec.info). Here follows my quick hack
for getting colorized output when running your specs trough
`autotest`. Put his in your `~/.autotest`:

```rb
def green(text)
  "\e[32m#{text}\e[0m"
end

def red(text)
  "\e[31m#{text}\e[0m"
end

Autotest.add_hook :ran_command do |at|
  if at.results.last
    bar = '=' * at.results.last.strip.length
    status = at.results.last.strip.scan /(\d+) (failure|error)s?/

    status.reject! { |ary| ary.first.to_i > 0 }

    status.empty? ? puts(red(bar)) : puts(green(bar))
  end
end
```
