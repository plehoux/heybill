Heybill
=======

<p align="center">
  <a href="https://github.com/plehoux/Heybill">
    <img src="./preview.png">
  </a>
</p>

<p align="center">
  <strong>Heybill</strong> lets you automatically fetch your bills/invoices from the command line.<br><br>
  <a href="http://badge.fury.io/rb/heybill"><img src="https://badge.fury.io/rb/heybill@2x.png" alt="Gem Version" height="18"></a> <a href="https://travis-ci.org/plehoux/Heybill"><img src="https://travis-ci.org/plehoux/Heybill.png"></a>
</p>

## Installation ##

```
gem install heybill
```

You also need [PhantomJS](http://phantomjs.org/download.html) >= 1.8.1.

## Usage ##

```
heybill fetch [PROVIDER] --from 'june 2012' --to 'last month' --save-to ~/Documents/expenses
```

## List of supported providers ##

- Amazon Web Services
- Heroku
- GitHub
- Webfaction
- Hetzner
- Videotron Affaires/Business
- Pingdom
- Telus Mobility

## Contribute ##

Heybill is a scraping application, it needs care, it needs you.

Fork. Add/Fix a provider. Pull request.

Provider's class are built around the [Capybara](https://github.com/jnicklas/capybara)/[Poltergeist](https://github.com/jonleighton/poltergeist) DSL + helper methods.

```ruby
module Heybill
  module Providers
    class Acme < Heybill::Provider
      ask :email
      ask :password

      log_in do
        # Do stuff to log in using Capybara dsl
        # @email and @password available from the 'ask' mehtods above
      end

      fetch_bills do
        # Find every html or PDF invoices included between self.from and self.to
        # Save each invoice with one of those two helpers:

        # If invoice an html document:
        visit('http://acme.com/invoices/1')
        save_page_as_bill(date)

        # If invoice a PDF:
        save_pdf_as_bill(date, 'http://acme.com/invoices/1.pdf')
      end
    end
  end
end
```

## License ##

The MIT License (MIT)

Copyright (c) 2013 Philippe-Antoine Lehoux

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
