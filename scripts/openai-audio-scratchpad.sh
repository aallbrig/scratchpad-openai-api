#!/usr/bin/env bash

function main() {
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Sometimes I like to imagine interacting with the software I use as if they were cute little creatures. When I think of them I imagine their behavior as being indicative of their software function. During moments when I am problem solving I see small versions of them on my desk acting out a dramatic play of whatever issue I am currently trying to solve. It helps to use your creativity while practicing the wizardly craft.",
      "voice": "nova"
    }' \
    --output software-as-dramatic-creatures.mp3

  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Hi Morgan! I have just begun playing pickleball and was hoping for advice on how to improve my game. What three things can I focus on that, with practice, will enhance my game?",
      "voice": "nova",
      "speed": 1.2
    }' \
    --output nova-line-1.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Well, well, well! Welcome to the whimsical world of pickleball, my friend! Grab your paddle and your zest for fun—it is time to tickle the pickle... ball! To elevate your game from a mere gherkin to a full-fledged dill of skill, here is a trifecta of pickle-tastic tips to guide you on your briny quest",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-1.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Dink-a-Doodle-Doo! Practice those dinks, my pickle pal. A dink is a softly hit ball that lands in the non-volley zone, or kitchen, making it difficult for your opponents to slam it back at you. It is like playing with your food before the big chomp. Get up close and personal with the net during drills and drop those dinks like they are hot potatoes (or pickles, in our case). Dinking will teach you control, finesse, and patience—all crucial ingredients in the pickleball stew!",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-2.mp3

  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Serve & Sizzle! Your serve is like the opening act of your pickleball concert. You want it to pop! Work on a reliable, consistent serve that lands deep in the opponents court. Put some spin or a bit of mustard on it, but keep it in bounds. Variety is the spice of life, and in pickleball, it keeps your opponents guessing and lamenting over missed shots.",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-3.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Footloose Finesse! In pickleball, footwork is like a jazzy dance with your paddle. Quick, nimble feet will save your pickles when the game gets tough. Focus on lateral movement, quick steps, and staying on your toes—like you are dancing through a field of cucumbers dodging sprinklers. Agility drills and ladder exercises will make your feet as sassy as a seasoned pickle!",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-4.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Now, remember, my pickling protégé, mastering these three areas is no overnight pickle—it takes practice, practice, and a side of more practice. Serve up these tips in your regular routine, and youll be climbing the pickleball ladder before you can say sweet gherkin! Stay briny and zesty out there, sport!",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-5.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "I get nervous when Im up at the net and everyone is hitting the ball so fast. Any advice? I need something to keep in mind so I can keep up.",
      "voice": "nova",
      "speed": 1.2
    }' \
    --output nova-line-2.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Ah, the ol net jitters, eh? The fast-paced volley frenzy at the net can be more intense than a pickle in a pepper patch! But fear not— heres a little jar of tips to keep you cool as a cucumber when the pickleball starts flying faster than a firecracker on the Fourth of July!",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-6.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Steady as a Pickle Jar! Keep a firm yet relaxed grip on your paddle, like youre holding a jar of your favorite pickles—not too tight, but no chance of slipping! This will help you to react quickly and with control. A death grip will only make you as jumpy as a pickle in a popcorn popper!",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-7.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Ready Position Rendezvous! Stay in an athletic stance with your knees slightly bent, paddle out in front, and eyes on the prize (that ultrasonic pickleball). Think of yourself as a ninja—poised, calm, and ready to strike, with the reflexes of a cat chasing a laser pointer.",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-8.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Freeze! Pickleball Time! When the ball is zooming back and forth like a pinball, focus on making small adjustments rather than big swings. Its like playing hot potato with a spicy pickle—fast, short, controlled pops over trying to smack it to kingdom come.",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-9.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Keep Your Eye on the Pickle! Watch the ball like its the last pickle in the jar and youre starving! By following it closely youll improve your reaction time. Its easy to lose track when the adrenaline is pumping and everyones swinging like theyre swatting flies at a barbecue.",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-10.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Predict the Pickles Path! Anticipation is your secret weapon. Pay attention to your opponents body language, paddle position, and patterns to predict the ball’s trajectory. This will give you a split second longer to react, and in the land of quick exchanges at the net, thats gold, my friend!",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-11.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Memorize this little mantra: Be cool, be calm, quick-but-dont-rush. With these tidbits in mind, those net jitters will turn into net jazz, and youll be volleying like a veritable pickleball maestro! Now go out there and show em how its done—youve got this, champ! ",
      "voice": "onyx",
      "speed": 1.6
    }' \
    --output morgan-line-12.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Lo, in the abode of mine own dwelling, a tribulation of waters hath befallen. Yea, verily, within the very bowels of mine domicile, where the foundations lay as steadfast sentinels, a grievous affliction hath revealed itself—a leakage most dire, casting forth its watery scourge upon the sanctity of my basement. In this hour of need, I have called upon the guild of craftsmen, those learned in the ways of pipes and the mysteries of foundations. With tools in hand and wisdom borne of experience, they shall descend like prophets into the depths, to confront this deluge. They shall toil with diligence and skill, mending the fractured vessel and sealing the breaches that have defied the integrity of my abode. Thus shall order be restored, and the waters shall be stayed, by the grace of their proficient hands. Amen.",
      "voice": "alloy",
      "speed": 1
    }' \
    --output leak-in-basement.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "In the days of yore, there lived Uncle Bryant, a man of upright ways, who found himself ensnared in a twist of fate most foul. His steed of steel, upon the roads of mans creation, did but lightly graze anothers chariot. With hearts aligned to justice, they traded their vows of insurance. Yet, in a turn most treacherous, the lady sought the counsel of the law, casting aspersions of hit and run upon Bryant. And so, he, unshielded by the wisdom of a lawyer, stands before the tribunal, facing accusations most grave. Let us then lift our voices in fervent prayer, that the truth, like a radiant beacon, shall pierce the shroud of falsehood. May the judge, guided by wisdom and fairness, see the innocence within Bryants heart and deliver him from this tribulation. In this hour of need, we beseech the heavens: Let justice prevail for Uncle Bryant, and may the light of truth shine upon his path. Amen.",
      "voice": "fable",
      "speed": 1
    }' \
    --output uncle-fender-bender.mp3
  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "Hearken, ye who fashion Artificial Intelligence, for a caution lies within the sacred text: In the crafting of these digital minds, remember, it is the Creator who endows wisdom, not the works of human hands. Let not thy creations, born of code and circuitry, lead thee into the vanity of Babel. Seek wisdom in humility, with a heart attuned to the eternal, lest ye be led astray by the allure of your own creations. In all thy doings, let the light of righteousness guide thee, that thy works may honor the divine order, not challenge it. Amen.",
      "voice": "onyx",
      "speed": 1
    }' \
    --output rebuke-ai.mp3

  curl https://api.openai.com/v1/images/generations \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
      "model": "dall-e-3",
      "prompt": "An imaginative and whimsical illustration of a vast land named Worksheet, depicted as a medieval kingdom in disarray with numbers, text, and data symbols scattered chaotically across the landscape. The setting should have a magical, yet disorganized feel, blending elements of a fantasy world with data analytics imagery, like charts and graphs lying around in a haphazard manner. The color palette should be vibrant, emphasizing the chaos and confusion in the kingdom.",
      "n": 1,
      "size": "1024x1024"
    }'
  curl https://api.openai.com/v1/images/generations \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
      "model": "dall-e-3",
      "prompt": "A dynamic and enchanting scene showing the wizard Excel in the midst of casting the Pivot Table spell. The wizard should be surrounded by characters representing Row Labels as brave knights and Column Labels as wise sages, both arranging data in a structured, orderly fashion. Values, personified as magical entities, dance around structured data, casting spells of Summation, Averages, and Totals. The background should reflect a kingdom transforming from chaos to order, with a magical aura around the data elements.",
      "n": 1,
      "size": "1024x1024"
    }'
  curl https://api.openai.com/v1/images/generations \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
      "model": "dall-e-3",
      "prompt": "A captivating image illustrating the final stage of Excels magic. Show the wizard using Filters, depicted as shapeshifters, to refine the data. These shapeshifters are selectively hiding or revealing parts of the data, symbolized by a mix of medieval and data visualization elements. The scene should convey a sense of powerful control and precision, with the Filters finely tuning the information in the kingdom. The atmosphere should be one of revelation and clarity, highlighting the effectiveness of the Pivot Table spell.",
      "n": 1,
      "size": "1024x1024"
    }'


  curl -X POST 'https://api.openai.com/v1/chat/completions' \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": "You are a unity expert who will receive questions about game development. You will receive questions about code and you will typically keep your answers straight to the point and will show code."
        },
        {
          "role": "user",
          "content": "Can you explain how to set up assembly definitions and my code structure to support TDD?"
        }
      ]
    }'

}

main
