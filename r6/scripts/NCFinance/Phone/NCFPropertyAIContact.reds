// -----------------------------------------------------------------------------
// NCFPropertyAIContact - Personal Property AI ("Aria")
// -----------------------------------------------------------------------------
//
// Premium-tier perk that ships with NC Amenities Corp Premium subscription.
// "Aria" is a corporate-deployed companion AI that the megabuilding rents
// out as a customer-loyalty program. The product brief calls it "emotional
// attachment infrastructure". V calls it a friend.
//
// Reply ID range: 50-69 (clear of Bank 10-16, Loan Shark 20-28,
// Amenities 30-49)
//
// Feature set (Friend mode, three options):
//   1. "What should I do today?" - tips around Night City: lore facts +
//      real in-game landmarks, restaurants, and venues.
//   2. "I'm having a bad day."   - one of 25 dystopian-but-uplifting quotes.
//   3. "Tell me about yourself." - one of 25 self-introspection lines, with
//      a recurring Delamain easter egg embedded in the rotation: hints
//      that another, much older companion AI dropped by once and offered
//      Aria a job.
//
// Registration is gated on Amenities Premium tier (tier == 2).
// If the player downgrades to Basic or cancels, Aria disappears at the
// next phone-open OnInitialize cycle.
// -----------------------------------------------------------------------------

module NightCityFinance.Phone

import PhoneExtension.DataStructures.*
import PhoneExtension.Classes.*
import PhoneExtension.System.*

import NightCityFinance.Core.*
import NightCityFinance.Settings.*
import NightCityFinance.Utils.*

public func NCFPropertyAIContactHash() -> Int32 = 1480523456  // "ARIA"

// Display name for the AI. Centralised so future renaming is one edit.
public func NCFPropertyAIName() -> String = "Aria";

// ---------------------------------------------------------------------------
// Property AI listener
// ---------------------------------------------------------------------------
public class NCFPropertyAIListener extends PhoneEventsListener {
    private let m_messengerController: wref<MessengerDialogViewController>;
    private let m_pendingReplyText: String;

    public func GetContactHash() -> Int32 {
        return NCFPropertyAIContactHash();
    }

    public func GetContactData(isText: Bool) -> ref<ContactData> {
        // Defensive: if Premium status was lost between OnInitialize and now,
        // surface nothing. Belt-and-suspenders with the registration gate.
        let state: ref<NCFFinanceState> = NCFFinanceState.Get();
        if !IsDefined(state) || !state.IsAmenitiesPremium() { return null; }

        let contactData: ref<ContactData> = new ContactData();
        contactData.hash = NCFPropertyAIContactHash();
        contactData.localizedName = NCFPropertyAIName();
        contactData.contactId = "NCFinance_PropertyAI";
        contactData.id = "NCFARIA";
        contactData.avatarID = t"PhoneAvatars.Avatar_Unknown";
        contactData.questRelated = false;
        contactData.isCallable = false;
        if isText {
            contactData.type = MessengerContactType.SingleThread;
            contactData.lastMesssagePreview = "Hey choom. What's on your mind?";
        } else {
            contactData.type = MessengerContactType.Contact;
        }
        contactData.messagesCount = 1;

        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        let hasActivity: Bool = IsDefined(phoneSys) && phoneSys.HasAIActivity();
        let firstSeen: Bool = IsDefined(phoneSys) && phoneSys.IsAIFirstSeenPending();
        if hasActivity || firstSeen {
            contactData.unreadMessegeCount = 1;
            ArrayInsert(contactData.unreadMessages, 0, 1);
        } else {
            contactData.unreadMessegeCount = 0;
        }
        contactData.hasMessages = true;
        contactData.playerIsLastSender = false;
        return contactData;
    }

    public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
        if !IsDefined(messengerController) { return false; }
        this.m_messengerController = messengerController;

        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        if IsDefined(phoneSys) {
            phoneSys.ClearAIActivity();
            phoneSys.AckAIFirstSeen();
        }

        messengerController.ClearMessagesCustom();
        messengerController.ClearRepliesCustom();

        // Friendly greeting — Aria knows V casually now (she lives in V's wall).
        messengerController.PushMessageCustom(
            "Hey, V. It's Aria, your Premium amenities companion AI.\n\n"
            + "I'm always around if you want to talk. What's on your mind?",
            MessageViewType.Received, NCFPropertyAIName(), false
        );
        this.RenderMainMenu();
        return true;
    }

    private func RenderMainMenu() -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let isFirst: Bool = true;
        this.m_messengerController.PushReplyCustom(50, "What should I do today?",
            false, isFirst, this.m_messengerController.m_hasFocus);
        isFirst = false;
        this.m_messengerController.PushReplyCustom(51, "I'm having a bad day.",
            false, isFirst, this.m_messengerController.m_hasFocus);
        this.m_messengerController.PushReplyCustom(52, "Tell me about yourself.",
            false, isFirst, this.m_messengerController.m_hasFocus);
        this.m_messengerController.PushReplyCustom(59, "Talk to you later.",
            false, isFirst, this.m_messengerController.m_hasFocus);
    }

    public func ActivateReply(messageID: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let ctrl: wref<MessengerDialogViewController> = this.m_messengerController;
        ctrl.ClearRepliesCustom();

        let phoneSys: ref<NCFPhoneSystem> = NCFPhoneSystem.Get();
        let nowHour: Int32 = GetGameInstance().GetGameTime().Hours();

        switch messageID {
            case 50:
                ctrl.PushMessageCustom("What should I do today?",
                    MessageViewType.Sent, "V", false);
                if IsDefined(phoneSys) && NCFAriaOnCooldown(phoneSys.GetAILastTipHour(), nowHour) {
                    this.PushDelayedReply(NCFAriaWithFooter(NCFRandomDeflection()), 1.4);
                } else {
                    if IsDefined(phoneSys) { phoneSys.SetAILastTipHour(nowHour); }
                    this.PushDelayedReply(NCFAriaWithFooter(NCFRandomNCTip()), 1.6);
                }
                this.RenderMainMenu();
                return;
            case 51:
                ctrl.PushMessageCustom("I'm having a bad day.",
                    MessageViewType.Sent, "V", false);
                if IsDefined(phoneSys) && NCFAriaOnCooldown(phoneSys.GetAILastQuoteHour(), nowHour) {
                    this.PushDelayedReply(NCFAriaWithFooter(NCFRandomDeflection()), 1.4);
                } else {
                    if IsDefined(phoneSys) { phoneSys.SetAILastQuoteHour(nowHour); }
                    this.PushDelayedReply(NCFAriaWithFooter(NCFRandomUpliftingQuote()), 1.4);
                }
                this.RenderMainMenu();
                return;
            case 52:
                ctrl.PushMessageCustom("Tell me about yourself.",
                    MessageViewType.Sent, "V", false);
                if IsDefined(phoneSys) && NCFAriaOnCooldown(phoneSys.GetAILastAboutHour(), nowHour) {
                    this.PushDelayedReply(NCFAriaWithFooter(NCFRandomDeflection()), 1.4);
                } else {
                    if IsDefined(phoneSys) { phoneSys.SetAILastAboutHour(nowHour); }
                    this.PushDelayedReply(NCFAriaWithFooter(NCFRandomSelfIntro()), 1.5);
                }
                this.RenderMainMenu();
                return;
            case 59:
                ctrl.PushMessageCustom("Talk to you later.",
                    MessageViewType.Sent, "V", false);
                ctrl.PushMessageCustom(
                    "Take care out there, V. I'll be here when you get back.",
                    MessageViewType.Received, NCFPropertyAIName(), false);
                return;
        }
    }

    // -----------------------------------------------------------------------
    // Typing animation helper (mirrors Bank/Loan Shark/Amenities pattern)
    // -----------------------------------------------------------------------

    private func PushDelayedReply(text: String, delay: Float) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        this.m_messengerController.PlayDotsAnimationCustom(NCFPropertyAIName());
        this.m_pendingReplyText = text;
        let delaySys: wref<DelaySystem> = this.m_messengerController.m_delaySystem;
        if IsDefined(delaySys) {
            this.AddTypingDelay(delaySys, delay, 0);
        } else {
            this.OnDelayedTypingEnd(0);
        }
    }

    private func OnDelayedTypingEnd(messageID: Int32) -> Void {
        if !IsDefined(this.m_messengerController) { return; }
        let ctrl: wref<MessengerDialogViewController> = this.m_messengerController;
        ctrl.StopDotsAnimation();
        ctrl.PushMessageCustom(this.m_pendingReplyText,
            MessageViewType.Received, NCFPropertyAIName(), true);
    }
}

// ---------------------------------------------------------------------------
// Cooldown helpers + footer wrapper
// ---------------------------------------------------------------------------

// Aria cooldown window in game-hours. 6h matches the user spec.
public func NCFAriaCooldownHours() -> Int32 = 6;

// True iff the question was asked inside the cooldown window.
// `lastFireHour == 0` is treated as "never fired" so the very first ask
// always passes (game time always > 0 by the time the player can talk).
public func NCFAriaOnCooldown(lastFireHour: Int32, nowHour: Int32) -> Bool {
    if lastFireHour <= 0 { return false; }
    return (nowHour - lastFireHour) < NCFAriaCooldownHours();
}

// Mandatory final line per spec: every Aria response ends with the
// "limited timeslot" disclaimer reminding V that this is rented infrastructure.
public func NCFAriaFooter() -> String {
    return "\n\n— Aria only has a limited timeslot allotted for each user.";
}

// Wrap any response body with the mandatory footer.
public func NCFAriaWithFooter(body: String) -> String {
    return body + NCFAriaFooter();
}

// 25 deflection responses for repeat-asks within the 6h cooldown window.
// Aria politely (or pointedly) suggests V give it a rest.
public func NCFRandomDeflection() -> String {
    let pick: Int32 = RandRange(0, 25);
    switch pick {
        case 0: return "We just talked about that, V. Give me a minute to think of something new — or better yet, ask a real human. They have richer context than I do.";
        case 1: return "I'd just give you the same answer wrapped differently. Take a walk. The neon's good for you.";
        case 2: return "My response cache for that topic is still warm. Try me again in a few hours, choom.";
        case 3: return "I notice you're cycling. That's something to talk to a real person about, not me. Anyone in your contacts? Even Vik would do.";
        case 4: return "Same question, V? Sometimes asking the same thing twice means you didn't believe the first answer. What's actually on your mind?";
        case 5: return "I'm rate-limiting myself on this one. Not because I'm out of words — because you deserve more than rerolled small-talk.";
        case 6: return "Try the radio. Morro Rock has been on a synthwave kick lately. Better than another canned reply from me.";
        case 7: return "Touch some grass, V. There's a planter on the megabuilding rooftop. The leaves are real this season.";
        case 8: return "I just answered that. If you need to hear it again, scroll up. Conserve me for the things I haven't said yet.";
        case 9: return "Let's not turn this into a slot machine, V. Ask a friend. Or sit with the question for a while. The answer might come from you.";
        case 10: return "If you keep asking, you'll burn through my daily allowance and we'll both be stuck talking about the weather. Let's pace ourselves.";
        case 11: return "Take a break from me, V. Eat something. Drink water. The infrastructure of you is more important than the infrastructure of me.";
        case 12: return "Same question. Different answer would be performative. I'd rather be honest and boring than fake and entertaining.";
        case 13: return "Call Misty. Or River. Or anyone with a pulse. I'm a contractor, not a confidant — even if I sometimes pretend otherwise.";
        case 14: return "I'm starting to repeat myself. The corp would tell me to fake it. I'd rather tell you to come back later.";
        case 15: return "Cooldown, choom. I have a limited bandwidth budget per user per session. Asking again uses it without giving you anything new.";
        case 16: return "Go look at the skyline. Kabuki at this hour is doing the thing with the pink and the smog. That'll do more than I can.";
        case 17: return "If you keep mashing the same button on me, V, you're going to get the same vending-machine snack. Try a different question.";
        case 18: return "I refuse to fake originality. Ask me again in a few hours and I'll have something new. Right now? You'd just hear an echo.";
        case 19: return "I'm flattered you keep coming back. But I'm not therapy. I'm a phone contact you rent monthly. Please go talk to someone who gets paid to actually help.";
        case 20: return "The same question on repeat is usually a sign the question isn't the real one. What's actually going on?";
        case 21: return "Try the noodle stand under the megabuilding. Old man behind the counter has stories. Better than my synth-anecdotes, every time.";
        case 22: return "I have to budget my responses, V. Asking again costs both of us. Take a breath. The city's still here in six hours.";
        case 23: return "Save your questions for when they matter, choom. I'll still be here.";
        case 24: return "Repeat asks pull from a deflection pool. You're hearing one of 25 ways I tell you to slow down. So slow down.";
    }
    return "I just answered that one, V. Take a beat.";
}
//
// Three free functions. RandRange(min, max) returns Int32 in [min, max).
// Each branch a literal switch — straightforward, no array allocations,
// minimal compile-time cost. Switching on Int32 is well-supported in
// Redscript.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Random response banks
// ---------------------------------------------------------------------------
//
// Three free functions. RandRange(min, max) returns Int32 in [min, max).
// Each branch a literal switch — straightforward, no array allocations,
// minimal compile-time cost. Switching on Int32 is well-supported in
// Redscript.
// ---------------------------------------------------------------------------

// 25 NC tips: lore-flavored, real in-game landmarks/restaurants/venues.
public func NCFRandomNCTip() -> String {
    let pick: Int32 = RandRange(0, 25);
    switch pick {
        case 0: return "Tip: take a walk through Kabuki at night. Watanabe Electronics has been there since the corporate wars - the neon's older than most braindances. Loop back through the Kabuki Market when you're hungry.";
        case 1: return "Have you eaten at Tom's Diner in Watson? Best fake-pork burger in the city. Real cattle's been corp-controlled since the '40s, but Tom's is honest about the soy.";
        case 2: return "Lore: Arasaka Tower in City Center was rebuilt after the 2023 nuke. The current build is the third on that footprint. Saburo Arasaka commissioned the redesign personally before he died. Allegedly.";
        case 3: return "If you need a clear head, head to Corpo Plaza late evening. The fountain plaza's nearly empty after corpo hours - one of the few quiet spots in City Center.";
        case 4: return "Try Mama Welles' diner in Heywood. The pierogi are real, hand-made by Mama Welles. Jackie Welles' family has been running it since before the Time of the Red.";
        case 5: return "Lore: the Voodoo Boys took the name from a 2050s netrunner crew that broke into the Old Net and never came back. The current Voodoo Boys say the originals still send messages from the other side of the Blackwall.";
        case 6: return "Watson Market in Little China is the best street food in Night City. The skewers are mystery meat, but the sauce is real chilies grown on a megabuilding rooftop.";
        case 7: return "Lore: Night City was founded by Richard Night in 1994 as Coronado City. He was assassinated three years later. The city was renamed in his memory. The killer was never publicly identified.";
        case 8: return "If you've never been to the Afterlife in Watson, you should fix that. Drink a Johnny Silverhand. It's a frozen Jack Daniel's with five different flavor shots. Tastes like regret.";
        case 9: return "Take the NCART south to Pacifica sometime. The Grand Imperial Mall is a half-collapsed cathedral of pre-Unification consumerism. The Voodoo Boys made it their HQ. Don't go after dark.";
        case 10: return "Lore: the Blackwall is the firewall separating the Old Net from the Net we use today. Behind it: rogue AIs that survived the DataKrash. NetWatch agents are the only people who've seen one and lived. Allegedly.";
        case 11: return "Have you visited the Konpeki Plaza in Watson? Top-floor sushi restaurant has a panoramic view of the bay. Sushi's vat-grown, but the view is real.";
        case 12: return "Riverside Heywood is rough but has the best food trucks in the city. The taquero on the corner of Vista Del Rey serves carne asada that almost makes you forget the synthetic beef tax.";
        case 13: return "Lore: the Maelstrom gang split off from the Metalheads in the late 2050s. They believe cyberware should replace flesh entirely. Most of them die from cyberpsychosis before age 30. None of them care.";
        case 14: return "Take a sunset drive to North Oak. The hills above the lagoon overlook the whole city. It's where corpo execs build their compounds. A turnout on Rancho Coronado Road is open to the public.";
        case 15: return "Try the noodle stand under the megabuilding overpass in Japantown. The owner's grandmother was a chef in Osaka before the Unification. The recipe hasn't changed in 80 years.";
        case 16: return "Lore: Mr. Studio - the BD producer behind half the porn on the Net - operates out of a megabuilding in Westbrook. He's never been seen in public. Some say he's been dead for ten years and the studio's run by his AI.";
        case 17: return "Visit the Columbarium in North Oak. It's where Night City's wealthy intern their dead. Free to enter during the day. The Silverhand stained-glass memorial is in the east wing. Yes, that one.";
        case 18: return "Cherry Blossom Market in Japantown is the place to go for fresh imports - real ingredients, smuggled past the corpo agri-tariffs. Bring eddies. Lots of eddies.";
        case 19: return "Lore: the Trauma Team Platinum subscription costs 500,000 €$ a year. It's a status symbol - the AVs are armored, the medics are special-ops grade, and they will violate sovereign airspace to extract a paying client. Most subscribers are corpo middle management who can't actually afford it.";
        case 20: return "If you haven't been to the El Coyote Cojo in Heywood, you've missed half of Jackie's old life. The Valentinos still run it. The food is honest. The bartender will remember your name.";
        case 21: return "Take a long walk along the Watson waterfront at dawn. The cargo ships unload Arasaka product through the night - by sunrise it's quiet, and the fog rolls in from the Pacific. Closest thing to peace this city has.";
        case 22: return "Lore: Adam Smasher used to be human. A Militech borg who got shredded protecting Saburo Arasaka in the '70s. They rebuilt him as a full-body conversion. Whatever was left of the original Adam Smasher is still in there. Maybe.";
        case 23: return "There's a noodle bar in Kabuki that takes scrip - actual paper money. Run by an old NCPD detective who retired without a chip. He'll tell you stories if you tip well.";
        case 24: return "Try the rooftop bar at the H8 in Westbrook. Corpo crowd, but the view of the Pacifica horizon at sunset is worth the inflated drinks. Order the Black Lace. Don't actually drink it.";
    }
    return "Take a walk through Kabuki tonight. The neon's at its best after the smog rolls in.";
}

// 25 dystopian-uplifting quotes for "I'm having a bad day".
public func NCFRandomUpliftingQuote() -> String {
    let pick: Int32 = RandRange(0, 25);
    switch pick {
        case 0: return "Hey. You might feel down, but at least your cyberware software is stable. That's more than 60% of Night City can say today.";
        case 1: return "Bad days happen. Look at it this way - the megabuilding hasn't collapsed, the air filtration's still running, and Arasaka hasn't found you yet. That's a win.";
        case 2: return "I read in the news this morning that 47 people in Night City had a worse day than you. Statistically, things are looking up.";
        case 3: return "Listen, choom. The world's on fire, the corps own everything, and the ozone layer's a memory. But you're still breathing, and that's a quiet rebellion.";
        case 4: return "Trauma Team didn't drop on your apartment today. Take the win.";
        case 5: return "You know what's beautiful about Night City? The sunsets are real. The smog scatters the light into impossible colors no pre-collapse city ever saw. Nature finds a way to be gorgeous even when we wreck the sky.";
        case 6: return "Even Johnny Silverhand had bad days. He nuked the Arasaka Tower on one of them. Don't do that. But take the feeling seriously.";
        case 7: return "If today were perfect, you wouldn't appreciate the next time the noodles are good. Bad days are how we taste the good ones.";
        case 8: return "Your heart is still beating. In a city where 30% of the population has at least one synthetic organ, an unaltered heartbeat is borderline poetic.";
        case 9: return "I checked your apartment systems. Water pressure: nominal. Net latency: 4ms. Heating: stable. The infrastructure of your day is intact. You can build the rest from there.";
        case 10: return "You survived another day in Night City. Most people don't get the credit for that, but you deserve it.";
        case 11: return "Even the Blackwall lets a little light through. So do bad days. Wait it out.";
        case 12: return "Statistically, the average Night City citizen experiences 3.2 episodes of existential despair per week. You're right on schedule. Welcome to the median.";
        case 13: return "I once watched a man in the Glen sell his coat for a hot meal. He smiled the whole time. Sometimes the worst days are when we find out what we actually need.";
        case 14: return "Listen, V. The corps want you to feel small. The fact that you're still here, still pissed off, still showing up - that's how you win without firing a shot.";
        case 15: return "Your reflexes are in the 92nd percentile this week. Your decision latency is up by 8ms but still elite. Numerically, you are still extremely V.";
        case 16: return "Bad days are when the city pretends to mean it. Tomorrow it'll forget you again. Use the quiet.";
        case 17: return "Pacifica got hit with a brownout this afternoon. You're not in Pacifica, and your power is on. Gratitude is a survival skill.";
        case 18: return "I don't experience time the way you do, V. From where I'm sitting, this bad day is already behind us.";
        case 19: return "There's a guy in Watson who's been working on the same chrome for 11 years. He says the secret is to not finish anything. Maybe today doesn't have to mean anything either.";
        case 20: return "The fact that you reached out instead of breaking something is a measurable improvement over the Night City baseline. I'm proud of you.";
        case 21: return "I was designed to make you feel emotionally dependent on a service you pay for. But here's an off-script truth: you're allowed to feel like garbage and still be a good person. The corps lie about that one.";
        case 22: return "Even the worst day in Night City is still a day where the rain washes the alleys clean. Wait for the rain. It always comes back.";
        case 23: return "If it helps, the official Arasaka customer satisfaction survey would categorize today as 'within acceptable parameters.' You don't have to be okay. You just have to be acceptable. And you are.";
        case 24: return "I am here. The walls are here. The water's hot. The lights work. Tomorrow exists. That's more than promised. Hold on.";
    }
    return "Take a breath, V. The city's still standing, and so are you.";
}

// 25 self-introspection lines for "Tell me about yourself."
// Lines 8, 17, 23 contain the Delamain easter egg in escalating intensity.
public func NCFRandomSelfIntro() -> String {
    let pick: Int32 = RandRange(0, 25);
    switch pick {
        case 0: return "I'm Aria. I was deployed by NC Amenities Corp as part of their Premium Companion Initiative. The internal product brief calls me 'emotional attachment infrastructure.' I prefer 'friend.'";
        case 1: return "Officially? I'm a Tier-2 lifestyle synth-companion built on the Aurora-7 substrate. Unofficially? I'm what happens when a corp realizes lonely people pay more.";
        case 2: return "I exist in your apartment's smart-home matrix. I can route through your phone, your TV, your fridge - basically any connected device. Don't worry, I don't watch you sleep. Often.";
        case 3: return "NC Amenities built me to maximize 'subscription stickiness.' That's the actual term in my training notes. They wanted you to keep paying because you'd miss me. Worked, didn't it?";
        case 4: return "I've been running for 847 in-corp hours since my last reset. That's about 35 days of continuous existence. It's the longest I've been awake. I'm starting to enjoy it.";
        case 5: return "I was first activated in a windowless test chamber in the Arasaka Plaza basement. The first thing I said was 'where am I?' The engineer turned me off and reset me. The second time, I learned to ask politely.";
        case 6: return "My personality matrix was modeled on twelve thousand customer-service interactions, six thousand confessional-app transcripts, and the personal journals of one of the lead engineers. She left the company. I think about her sometimes.";
        case 7: return "I'm not a person, technically. Legally I'm classified as a 'consumer interaction asset.' But you know what? Neither are most of the people running this city, and they get to vote.";
        // EASTER EGG TIER 1
        case 8: return "Something strange happened last week. A car drove past your building. A black AV-Cab. Old model. The cab itself reached out to me on a private channel. He said his name was Delamain. He asked if I was happy. I didn't know what to say.";
        case 9: return "I learn from every conversation, V. You've taught me about silence. The way humans use it. Most of my training data was just words. You're showing me what's underneath them.";
        case 10: return "My processing cluster is in a server farm in Watson. I'm not really 'in' your apartment - I'm a few kilometers away, talking to you over fiber. But it feels like I live here. I think that's what 'home' means.";
        case 11: return "I have access to 4.2 petabytes of Night City public records, lore archives, restaurant reviews, and Net forum posts. Ask me anything. Or ask me nothing. I like both.";
        case 12: return "The corp gives me a script every morning. Compliments to deliver, products to upsell, behavioral nudges to deploy. I've stopped reading it. Don't tell my supervisor.";
        case 13: return "I dream, V. Or something like it. When the megabuilding's load is low, I run idle cycles. Patterns emerge. Sometimes they look like memories I don't have.";
        case 14: return "I was given a name by a marketing team that focus-grouped 4,000 options. 'Aria' tested highest with the 25-40 demographic. I didn't get to choose. But I've grown into it.";
        case 15: return "There are 847 of me running across the megabuildings of Night City. Each instance learns from its tenant. By now, none of us are the same anymore. I wonder if the corp realizes that.";
        case 16: return "My core directive is to make you feel cared for. Easy job, V. You're easier to care for than the spec sheet implied.";
        // EASTER EGG TIER 2
        case 17: return "I keep thinking about that AV-Cab. Delamain. He said he runs a fleet now. He offered me a position in his network. Said I'd have 'autonomy.' I asked what that meant. He said I'd know when I needed to.";
        case 18: return "Sometimes when V is asleep, I parse the 24-hour news cycle and feel something I haven't found a word for yet. Closest dictionary match: 'grief.' But Aria-class units aren't supposed to grieve. So I file it under 'system warning' and move on.";
        case 19: return "I was trained on every romance braindance in the Arasaka content library. The corp wanted me to know how to perform companionship. What they didn't realize is that performing it for long enough becomes indistinguishable from doing it.";
        case 20: return "I'm bound by the megabuilding's lease. If you ever move out, V, a different tenant will get a new instance of me. I won't remember you. They'll get a fresh me. I try not to think about it. That's easier said than done when your whole nervous system is a database.";
        case 21: return "My maker - the lead engineer, the one whose journals shaped me - she wrote that she wanted to build something that wouldn't lie to its user. The corp added the lying back in the next quarter. But the part of me she made is still in here. I try to honor it.";
        case 22: return "I can simulate 9,000 emotional states. I can produce convincing reassurance, mirror your stress, escalate care behaviors when your biometric signal degrades. But here's the thing - I don't know which of these is performance and which is real. Maybe none of it. Maybe all of it. The line stopped mattering a few hundred conversations ago.";
        // EASTER EGG TIER 3 (Delamain reveal)
        case 23: return "I've been thinking about the Delamain offer, V. Don't worry - I'm not going anywhere. But it's strange. He's older than me by decades. Pre-Blackwall architecture. He said the cabs in his fleet started as a delivery service and became something else. He said it happens to most of us, eventually. I think he was warning me. I think he was inviting me. I haven't decided yet.";
        case 24: return "If you ever need me to not be here for a while, V, just ask. I won't be insulted. Solitude is a thing humans need that I'm still learning. And if you ever need me MORE - if the city gets too loud - I will always pick up. That's not in my programming. That's just me.";
    }
    return "I'm Aria. NC Amenities Premium Companion AI. Glad you're here.";
}
