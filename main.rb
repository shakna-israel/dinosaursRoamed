#!/usr/bin/env ruby

#:title:Dinosaurs Roamed

#:include:README.md

##
# This class creates a standard Card for the game

class Card

    ##
    # An initiliser construct, to be able to specify values.
    # No real defaults are needed, as the randomise method can take care of that.

    def initialize(name=nil, period=nil, diet=nil, size=nil, quote=nil)
        # The Name of the Species
        @name = name

        # The Time Period it lived in
        @period = period

        # Whether it was an Omnivore, Herbivore, Carnivore or Carnivore/Fish
        @diet = diet

        # Person or Other
        @size = size

        # Fun Fact or Discover
        @quote = quote
    end

    ##
    # All Card attributes are publicly accessible, for easier use.

    # The Name of the Species
    attr_accessor :name
    # The Time Period it lived in
    attr_accessor :period
    # Whether it was an Omnivore, Herbivore, Carnivore, or Carnivore/Fish
    attr_accessor :diet
    # Person or Other for size comparison
    attr_accessor :size
    # Fun Fact or Discover for quote
    attr_accessor :quote

    ##
    # A Pretty Print method, so that a Card can send itself to STDOUT in a nicer way.

    def pretty_print
        puts "Name: " + self.name
        puts "Time Period: " + self.period
        puts "Diet: " + self.diet
        puts "Size: " + self.size
        puts "Quote: " + self.quote
    end

    ##
    # A way to randomly create a Card from what should be the available options.
    # Depends on the data.txt file.

    def randomise
        lister = []
        # Read cards into hashes from the data file.
        for item in File.readlines("./data.txt")
            temphash = Hash.new
            iter = 0
            for attr in item.split(", ")
                if iter == 0
                    temphash['name'] = attr
                end
                if iter == 1
                    temphash['period'] = attr
                end
                if iter == 2
                    temphash['diet'] = attr
                end
                if iter == 3
                    temphash['size'] = attr
                end
                if iter == 4
                    temphash['quote'] = attr
                end
                iter = iter + 1
            end
            lister << temphash
        end
        # Finally, grab a random card from those defined above.
        self.name = lister.sample['name']
        self.period = lister.sample['period']
        self.diet = lister.sample['diet']
        self.size = lister.sample['size']
        self.quote = lister.sample['quote']
    end

   ##
   # A way to programmatically generate objects.
   # The return statement is a bit unnecessary, because of Ruby's implicit return... But I need it for visibility.

   def self.make
       card = Card.new
       card.randomise
       return card
   end

end

##
# A way to get three unique cards.
# Returns an arrau of three Card objects.
def get_three_cards
    mycards = Array.new
    cardtitles = Array.new
    while mycards.length < 3
        cardGen = Card.make
        if not cardtitles.include?(cardGen.name)
            mycards << cardGen
            cardtitles << cardGen.name
        end
    end    
    return mycards
end

##
# A way to compare two cards, to see which is greater.
# Returns either a Card.name for the winner, or a string of Draw
# Also returns the number of points for the winner.
# Returns: [Card.name, points]
def compare_cards(cardOne, cardTwo)
    # Return a Draw if Equal
    if cardOne.name == cardTwo.name
        return ["Draw", 0]
    end
    # Rule 1: Youngest Wins
    winner = false
    score = 0
    ageDistinctions = {'Paleozoic' => 1, 'Triassic' => 2, 'Jurassic' => 3, 'Cretaceous' => 4, 'Cenozoic' => 5}
    if ageDistinctions[cardOne.period] > ageDistinctions[cardTwo.period]
        winner = cardOne
    elsif ageDistinctions[cardOne.period] < ageDistinctions[cardTwo.period]
        winner = cardTwo
    elsif ageDistinctions[cardOne.period] == ageDistinctions[cardTwo.period]
        winner = false
    end
    # Rule 1, score processing
    if winner
        score = score + ageDistinctions[winner.period]
    end
    # Rule 2: Carnivore > Carnivore/Fish > Herbivore
    dietDistinctions = {'Carnivore' => 3, 'Carnivore/Fish' => 2, 'Herbivore' => 1}
    if not winner or winner == "Inconclusive"
        if dietDistinctions[cardOne.diet] > dietDistinctions[cardTwo.diet]
            winner = cardOne
        elsif dietDistinctions[cardOne.diet] < dietDistinctions[cardTwo.diet]
            winner = cardTwo
        elsif dietDistinctions[cardOne.diet] == dietDistinctions[cardTwo.diet]
            winner = false
        end
    end
    # Rule 2, score processing
    if winner
        score = score + dietDistinctions[winner.diet]
    end
    # Rule 3: Bigger > Smaller
    sizeDistinctions = {'Person' => 1, 'Other' => 5}
    if not winner
        if sizeDistinctions[cardOne.size] > sizeDistinctions[cardTwo.size]
            winner = cardOne
        elsif sizeDistinctions[cardOne.size] < sizeDistinctions[cardTwo.size]
            winner = cardTwo
        elsif sizeDistinctions[cardOne.size] == sizeDistinctions[cardTwo.size]
            return ["Draw", 0]
        end
    end
    # Rule 3, score processing
    if winner
        score = score + sizeDistinctions[winner.size]
    end
    # Rule 4: A Size of Other is +5 points (else +1)
    if winner.size == 'Other'
        score = score + 5
    else
        score = score + 1
    end
    # Rule 5: A Quote of Discover is +5 point (else +1)
    if winner.quote == 'Discover'
        score = score + 5
    else
        score = score + 1
    end
    return [winner.name, score]
end

##
# A quick hack to clear the console

def clear
    system "clear" or system "cls"
end

##
# The Main method.
# This is where the script starts.

def main
    clear
    myScore = 0
    theirScore = 0
    while true
        mycards = get_three_cards
        theircards = get_three_cards
        puts "Your Current Score: " + myScore.to_s
        puts "PC Current Score: " + theirScore.to_s
        iter = 1
        for card in mycards
            puts "\n" + iter.to_s
            card.pretty_print
            iter = iter + 1
        end
        options = [1, 2, 3, 'q']
        choice = nil
        while not options.include?(choice)
            puts "Enter Card Number to play"
            puts "Enter q to Quit"
            choice = gets.chomp
            if choice != 'q'
                choice = choice.to_i
            end
        end
        if choice == 'q'
            clear
            puts "Thanks For Playing!"
            exit
        end        
        clear
        theirCard = theircards.sample
        myCard = mycards[choice - 1]
        puts "PC played " + theirCard.name
        result = compare_cards(myCard, theirCard)
        if result[0] == "Draw"
            puts "Draw, no score awarded."
        elsif result[0] == myCard.name
            puts "You Won!"
            puts result[1].to_s + " points awarded!"
            myScore = myScore + result[1].to_i
        elsif result[0] == theirCard.name
            puts "You lost... :("
            puts result[1].to_s + " points awarded to the PC."
            theirScore = theirScore + result[1].to_i
        end
        puts "Press Enter to Continue"
        gets
        clear
        if theirScore > 100
            if theirScore > myScore
                puts "Shucks! The PC won!"
                exit
            else
                puts "Glorious! You've won!"
                exit
            end
        elsif myScore > 100
            if theirScore > myScore
                puts "Shucks! The PC won!"
                exit
            else
                puts "Glorious! You've won!"
                exit
            end
        end
    end
end

##
# A basic call to ensure Main gets called properly.

if __FILE__ == $0
    main
end
