class Ability
  include CanCan::Ability

  def initialize(user, ip_address)
    case user.try(:role).try(:name)
    when 'Administrator'
      can :manage, :all
    when 'Librarian'
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        manifestation.items.empty?
      end
      can [:read, :create, :update], Item
      can :destroy, Item do |item|
        item.checkouts.not_returned.empty?
      end
      can :manage, [Create, Realize, Produce, Own, Exemplify]
      can :index, Patron
      can :show, Patron do |patron|
        patron.required_role_id <= 3 #'Librarian'
      end
      can :create, Patron
      can [:update, :destroy], Patron do |patron|
        patron.required_role_id <= 3 #'Librarian'
        patron.user.role.name != 'Administrator' if patron.user
      end
      can [:read, :create, :update], User
      can :destroy, User do |user|
        user.checkouts.not_returned.empty? and user.role.name == 'User'
      end
      can :read, Bookstore
      can :manage, [Basket, Checkout, Checkin]
      can :read, Subject
      can :manage, Bookmark
      can :manage, [Question, Answer]
      can :read, [Classification, ClassificationType]
      can :read, [SubjectType, SubjectHeadingType]
      can :manage, SubjectHasClassification
      can :manage, [Subscribe, Subscription]
      can :manage, [Reserve, PurchaseRequest]
      can :manage, PictureFile
      can :manage, [PatronRelationship, ManifestationRelationship]
      can :manage, [Order, OrderList]
      can :read, [Country, Language]
      can :read, Library
      can :manage, Event
      can :read, EventCategory
      can :manage, InterLibraryLoan
      can :manage, [Inventory, InventoryFile]
      can :read, [License, Extent, Frequency, FormOfWork]
      can :read, [
        PatronRelationshipType, ManifestationRelationshipType
      ]
      can :read, UserGroup
      can :manage, BookmarkStat
      can :manage, [UserCheckoutStat, UserReserveStat]
      can :manage, [ManifestationCheckoutStat, ManifestationReserveStat]
      can :manage, Tag
      can :read, SearchEngine
      can :read, Role
      can :manage, [ResourceImportFile, PatronImportFile, EventImportFile]
      can :manage, ImportRequest
      can :read, PatronType
      can :read, MediumOfPerformance
      can :manage, Message
      can :manage, MessageRequest
      can :read, MessageTemplate
      can :read, LibraryGroup
      can :read, [UserGroup, UserGroupHasCheckoutType]
      can :manage, WorkHasSubject
      can :read, CarrierType
      can :read, CheckoutType
      can :read, CarrierTypeHasCheckoutType
      can :manage, CheckedItem
      can :manage, [CheckoutStatHasManifestation, CheckoutStatHasUser]
      can :manage, [ReserveStatHasManifestation, ReserveStatHasUser]
      can :read, [CirculationStatus, UseRestriction]
      can :read, [ResourceImportResult, PatronImportResult, EventImportResult]
      can :read, Shelf
      can :read, [RequestStatusType, RequestType]
      can :manage, Participate
      can :manage, MessageTemplate
      can :manage, ItemHasUseRestriction
      can :manage, Donate
      can :manage, BookmarkStatHasManifestation
      can :read, ContentType
      can :read, NiiType
      can :index, SearchHistory
      can [:show, :destroy], SearchHistory do |search_history|
        search_history.try(:user) == user
      end
      can :manage, [PatronMerge, PatronMergeList]
      can :manage, SeriesStatement
    when 'User'
      can :read, [Manifestation, Item]
      can :edit, Manifestation
      can :read, [Create, Realize, Produce, Own, Exemplify]
      can :index, Patron
      can :create, Patron
      can :update, Patron do |patron|
        patron.user == user
      end
      can :show, Patron do |patron|
        if patron.user == user
          true
        elsif patron.user != user
          true if patron.required_role_id <= 2 #name == 'Administrator'
        end
      end
      can :show, User
      can :update, User do |u|
        u == user
      end
      can :create, Bookmark
      can [:update, :destroy, :show], Bookmark do |bookmark|
        bookmark && bookmark.user == user
      end
      can :read, Library
      can :read, Shelf
      can :read, Subject
      can :create, Tag
      can :read, Tag
      can :create, [Question, Answer]
      can [:update, :destroy], [Question, Answer] do |object|
        object.user == user
      end
      can :read, [Event, EventCategory]
      can :read, [Country, Language, License]
      can :read, UserGroup
      can :read, WorkHasSubject
      can :read, [PatronRelationshipType, ManifestationRelationshipType]
      can :read, [SubjectHeadingType, SubjectHasClassification]
      can [:update, :destroy, :show], [
        Bookmark, Checkout, PurchaseRequest, Reserve
      ] do |object|
        object.try(:user) == user
      end
      can :index, Question
      can :create, Question
      can [:update, :destroy], [Question, Answer] do |object|
        object.user == user
      end
      can :show, [Question, Answer] do |object|
        object.user == user or object.shared
      end
      can [:index, :create], [
        Answer, Bookmark, Checkout, PurchaseRequest, Reserve
      ]
      can :read, PictureFile
      can :read, MediumOfPerformance
      can :read, LibraryGroup
      can :read, LendingPolicy
      can :read, [License, Extent, Frequency, FormOfWork]
      can :read, ContentType
      can :read, [CirculationStatus, Classification, ClassificationType]
      can :read, CarrierType
      can :read, BookmarkStat
      can :read, NiiType
      can :index, Message
      can :create, Message
      can [:update], Message do |message|
        message.sender == user
      end
      can [:show, :destroy], Message do |message|
        message.receiver == user
      end
      can :index, SearchHistory
      can [:show, :destroy], SearchHistory do |search_history|
        search_history.try(:user) == user
      end
      can :read, [PatronRelationship, ManifestationRelationship]
      can :read, SeriesStatement
    else
      can :read, Manifestation
      can :read, Item
      can :index, Patron
      can :show, Patron do |patron|
        patron.required_role_id == 1 #name == 'Guest'
      end
      can :read, [Create, Realize, Produce, Own, Exemplify]
      can :read, Country
      can :read, Event
      can :read, EventCategory
      can :read, Language
      can :read, Library
      can :read, Shelf
      can :read, Subject
      can :read, Tag
      can :index, Question
      can :show, [Question, Answer] do |object|
        object.user == user or object.shared
      end
      can :read, [ManifestationCheckoutStat, ManifestationReserveStat]
      can :read, [UserCheckoutStat, UserReserveStat]
      can :read, [PatronRelationshipType, ManifestationRelationshipType]
      can :read, [SubjectHeadingType, SubjectHasClassification]
      can :read, UserGroup
      can :read, WorkHasSubject
      can :read, [PatronRelationship, ManifestationRelationship]
      can :read, PictureFile
      can :read, NiiType
      can :read, MediumOfPerformance
      can :read, LibraryGroup
      can :read, LendingPolicy
      can :read, [License, Extent, Frequency, FormOfWork]
      can :read, ContentType
      can :read, [CirculationStatus, Classification, ClassificationType]
      can :read, CarrierType
      can :read, BookmarkStat
      can :read, [SubjectHeadingTypeHasSubject, SubjectHasClassification]
      can :index, Checkout
      can :read, SeriesStatement
    end
  end
end
