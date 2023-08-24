# RRule
Recurring events factory for google calendar

shutout to: https://freetools.textmagic.com/rrule-generator for giving the free tool to have na understanable logic
Google iCalendar documentation for recurring events: https://developers.google.com/calendar/api/concepts/events-calendars#recurring_events
RFC 5545 documentation: https://datatracker.ietf.org/doc/html/rfc5545

exaples:

Daily:
let rFactory = RRuleFactory(freq: .daily(RRuleFactory.CycleRepeat(every: 2)), end: .onDate(Date.now)) -> will generate: "RRULE:FREQ=DAILY;INTERVAL=2;UNTIL=20230728T000000Z"

Weekly:
let rFactory = RRuleFactory(freq: .weekly(RRuleFactory.WeeklyRepeat(repeatEvery: 2, byday: [.monday])), end: .after(10)) -> will generate: "RRULE:FREQ=WEEKLY;BYDAY=MO;INTERVAL=2;COUNT=10"

Monthly:
let rFactory = RRuleFactory(freq: .weekly(RRuleFactory.WeeklyRepeat(repeatEvery: 2, byday: [.monday, .tuesday, .thursday])), end: .never) -> will generate: "RRULE:FREQ=WEEKLY;BYDAY=MO,TU,TH;INTERVAL=2"

Yearly
let rFactory = RRuleFactory(freq: .yearly(RRuleFactory.YearlyRepeat(bymonth: .august, weekInMonth: RRuleFactory.WeekInMonthPosition(week: .last, day: .friday))), end: .never) -> will generate: "RRULE:FREQ=YEARLY;BYSETPOS=-1;BYDAY=FR;BYMONTH=8"
