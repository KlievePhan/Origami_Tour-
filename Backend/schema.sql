-- ============================================================================
-- OrigamiDB — SQL Server schema generated from EF Core code-first model
-- Source: Backend/Domain/*.cs, Backend/Data/AppDbContext.cs,
--         Backend/Migrations/20260608114344_InitialCreate.cs
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ASP.NET Core Identity tables
-- ----------------------------------------------------------------------------

CREATE TABLE AspNetRoles (
    Id               NVARCHAR(450)  NOT NULL,
    Name             NVARCHAR(256)  NULL,
    NormalizedName   NVARCHAR(256)  NULL,
    ConcurrencyStamp NVARCHAR(MAX)  NULL,
    CONSTRAINT PK_AspNetRoles PRIMARY KEY (Id)
);
CREATE UNIQUE INDEX RoleNameIndex ON AspNetRoles (NormalizedName) WHERE NormalizedName IS NOT NULL;

CREATE TABLE Categories (
    Id   INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(MAX)     NOT NULL,
    Slug NVARCHAR(450)     NOT NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (Id)
);
CREATE UNIQUE INDEX IX_Categories_Slug ON Categories (Slug);

CREATE TABLE AspNetUsers (
    Id                   NVARCHAR(450)   NOT NULL,
    -- Domain (ApplicationUser) columns
    DisplayName          NVARCHAR(MAX)   NOT NULL,
    AvatarUrl            NVARCHAR(MAX)   NULL,
    JoinedAt             DATETIME2       NOT NULL,
    Exp                  INT             NOT NULL,
    Level                INT             NOT NULL,
    TotalCompleted       INT             NOT NULL,
    TotalFoldTimeSeconds BIGINT          NOT NULL,
    FavoriteCategoryId   INT             NULL,
    CurrentStreak        INT             NOT NULL,
    LastFoldDate         DATETIME2       NULL,
    -- Standard IdentityUser columns
    UserName             NVARCHAR(256)   NULL,
    NormalizedUserName   NVARCHAR(256)   NULL,
    Email                NVARCHAR(256)   NULL,
    NormalizedEmail      NVARCHAR(256)   NULL,
    EmailConfirmed       BIT             NOT NULL,
    PasswordHash         NVARCHAR(MAX)   NULL,
    SecurityStamp        NVARCHAR(MAX)   NULL,
    ConcurrencyStamp     NVARCHAR(MAX)   NULL,
    PhoneNumber          NVARCHAR(MAX)   NULL,
    PhoneNumberConfirmed BIT             NOT NULL,
    TwoFactorEnabled     BIT             NOT NULL,
    LockoutEnd           DATETIMEOFFSET  NULL,
    LockoutEnabled       BIT             NOT NULL,
    AccessFailedCount    INT             NOT NULL,
    CONSTRAINT PK_AspNetUsers PRIMARY KEY (Id),
    CONSTRAINT FK_AspNetUsers_Categories_FavoriteCategoryId
        FOREIGN KEY (FavoriteCategoryId) REFERENCES Categories (Id) ON DELETE SET NULL
);
CREATE INDEX IX_AspNetUsers_FavoriteCategoryId ON AspNetUsers (FavoriteCategoryId);
CREATE INDEX EmailIndex ON AspNetUsers (NormalizedEmail);
CREATE UNIQUE INDEX UserNameIndex ON AspNetUsers (NormalizedUserName) WHERE NormalizedUserName IS NOT NULL;

CREATE TABLE AspNetRoleClaims (
    Id         INT IDENTITY(1,1) NOT NULL,
    RoleId     NVARCHAR(450) NOT NULL,
    ClaimType  NVARCHAR(MAX) NULL,
    ClaimValue NVARCHAR(MAX) NULL,
    CONSTRAINT PK_AspNetRoleClaims PRIMARY KEY (Id),
    CONSTRAINT FK_AspNetRoleClaims_AspNetRoles_RoleId
        FOREIGN KEY (RoleId) REFERENCES AspNetRoles (Id) ON DELETE CASCADE
);
CREATE INDEX IX_AspNetRoleClaims_RoleId ON AspNetRoleClaims (RoleId);

CREATE TABLE AspNetUserClaims (
    Id         INT IDENTITY(1,1) NOT NULL,
    UserId     NVARCHAR(450) NOT NULL,
    ClaimType  NVARCHAR(MAX) NULL,
    ClaimValue NVARCHAR(MAX) NULL,
    CONSTRAINT PK_AspNetUserClaims PRIMARY KEY (Id),
    CONSTRAINT FK_AspNetUserClaims_AspNetUsers_UserId
        FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE
);
CREATE INDEX IX_AspNetUserClaims_UserId ON AspNetUserClaims (UserId);

CREATE TABLE AspNetUserLogins (
    LoginProvider       NVARCHAR(450) NOT NULL,
    ProviderKey         NVARCHAR(450) NOT NULL,
    ProviderDisplayName NVARCHAR(MAX) NULL,
    UserId              NVARCHAR(450) NOT NULL,
    CONSTRAINT PK_AspNetUserLogins PRIMARY KEY (LoginProvider, ProviderKey),
    CONSTRAINT FK_AspNetUserLogins_AspNetUsers_UserId
        FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE
);
CREATE INDEX IX_AspNetUserLogins_UserId ON AspNetUserLogins (UserId);

CREATE TABLE AspNetUserRoles (
    UserId NVARCHAR(450) NOT NULL,
    RoleId NVARCHAR(450) NOT NULL,
    CONSTRAINT PK_AspNetUserRoles PRIMARY KEY (UserId, RoleId),
    CONSTRAINT FK_AspNetUserRoles_AspNetRoles_RoleId
        FOREIGN KEY (RoleId) REFERENCES AspNetRoles (Id) ON DELETE CASCADE,
    CONSTRAINT FK_AspNetUserRoles_AspNetUsers_UserId
        FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE
);
CREATE INDEX IX_AspNetUserRoles_RoleId ON AspNetUserRoles (RoleId);

CREATE TABLE AspNetUserTokens (
    UserId        NVARCHAR(450) NOT NULL,
    LoginProvider NVARCHAR(450) NOT NULL,
    Name          NVARCHAR(450) NOT NULL,
    Value         NVARCHAR(MAX) NULL,
    CONSTRAINT PK_AspNetUserTokens PRIMARY KEY (UserId, LoginProvider, Name),
    CONSTRAINT FK_AspNetUserTokens_AspNetUsers_UserId
        FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- Domain tables
-- ----------------------------------------------------------------------------

CREATE TABLE LevelDefinitions (
    Level       INT IDENTITY(1,1) NOT NULL,
    RequiredExp INT           NOT NULL,
    RankTitle   NVARCHAR(MAX) NOT NULL,
    CONSTRAINT PK_LevelDefinitions PRIMARY KEY (Level)
);

CREATE TABLE Achievements (
    Id            INT IDENTITY(1,1) NOT NULL,
    Code          NVARCHAR(450) NOT NULL,
    Name          NVARCHAR(MAX) NOT NULL,
    Description   NVARCHAR(MAX) NOT NULL,
    IconUrl       NVARCHAR(MAX) NOT NULL,
    ConditionText NVARCHAR(MAX) NOT NULL,
    ConditionType NVARCHAR(30)  NOT NULL, -- FirstFold | ModelsCompleted | StreakDays | CategoryMaster | TotalFoldMinutes
    Threshold     INT           NOT NULL,
    CONSTRAINT PK_Achievements PRIMARY KEY (Id)
);
CREATE UNIQUE INDEX IX_Achievements_Code ON Achievements (Code);

CREATE TABLE Models (
    Id               INT IDENTITY(1,1) NOT NULL,
    Name             NVARCHAR(MAX) NOT NULL,
    Author           NVARCHAR(MAX) NOT NULL,
    ThumbnailUrl     NVARCHAR(MAX) NOT NULL,
    HeroUrl          NVARCHAR(MAX) NOT NULL,
    Difficulty       NVARCHAR(10)  NOT NULL, -- Easy | Medium | Hard
    EstimatedMinutes INT           NOT NULL,
    PaperSize        NVARCHAR(MAX) NOT NULL,
    Description      NVARCHAR(MAX) NOT NULL,
    RatingAvg        DECIMAL(3,2)  NOT NULL,
    RatingCount      INT           NOT NULL,
    CompletionCount  INT           NOT NULL,
    Popularity       INT           NOT NULL,
    CreatedAt        DATETIME2     NOT NULL,
    CONSTRAINT PK_Models PRIMARY KEY (Id)
);
CREATE INDEX IX_Models_CreatedAt ON Models (CreatedAt);
CREATE INDEX IX_Models_Difficulty ON Models (Difficulty);
CREATE INDEX IX_Models_EstimatedMinutes ON Models (EstimatedMinutes);
CREATE INDEX IX_Models_Popularity ON Models (Popularity);

CREATE TABLE FoldSteps (
    Id           INT IDENTITY(1,1) NOT NULL,
    ModelId      INT           NOT NULL,
    StepOrder    INT           NOT NULL,
    DiagramUrl   NVARCHAR(MAX) NOT NULL,
    AnimationUrl NVARCHAR(MAX) NULL,
    Instruction  NVARCHAR(MAX) NOT NULL,
    FoldType     NVARCHAR(15)  NOT NULL, -- Valley | Mountain | Squash | Reverse | Other
    CONSTRAINT PK_FoldSteps PRIMARY KEY (Id),
    CONSTRAINT FK_FoldSteps_Models_ModelId
        FOREIGN KEY (ModelId) REFERENCES Models (Id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX IX_FoldSteps_ModelId_StepOrder ON FoldSteps (ModelId, StepOrder);

CREATE TABLE ModelCategories (
    ModelId    INT NOT NULL,
    CategoryId INT NOT NULL,
    CONSTRAINT PK_ModelCategories PRIMARY KEY (ModelId, CategoryId),
    CONSTRAINT FK_ModelCategories_Models_ModelId
        FOREIGN KEY (ModelId) REFERENCES Models (Id) ON DELETE CASCADE,
    CONSTRAINT FK_ModelCategories_Categories_CategoryId
        FOREIGN KEY (CategoryId) REFERENCES Categories (Id) ON DELETE CASCADE
);
CREATE INDEX IX_ModelCategories_CategoryId ON ModelCategories (CategoryId);

CREATE TABLE Favorites (
    Id      INT IDENTITY(1,1) NOT NULL,
    UserId  NVARCHAR(450) NOT NULL,
    ModelId INT           NOT NULL,
    AddedAt DATETIME2     NOT NULL,
    CONSTRAINT PK_Favorites PRIMARY KEY (Id),
    CONSTRAINT FK_Favorites_AspNetUsers_UserId
        FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE,
    CONSTRAINT FK_Favorites_Models_ModelId
        FOREIGN KEY (ModelId) REFERENCES Models (Id) ON DELETE NO ACTION -- Restrict
);
CREATE INDEX IX_Favorites_ModelId ON Favorites (ModelId);
CREATE UNIQUE INDEX IX_Favorites_UserId_ModelId ON Favorites (UserId, ModelId);

CREATE TABLE Progresses (
    Id                     INT IDENTITY(1,1) NOT NULL,
    UserId                 NVARCHAR(450) NOT NULL,
    ModelId                INT           NOT NULL,
    Completed              BIT           NOT NULL,
    CurrentStep            INT           NOT NULL,
    AccumulatedTimeSeconds BIGINT        NOT NULL,
    BestTimeSeconds        BIGINT        NULL,
    LastSessionDate        DATETIME2     NOT NULL,
    StartedAt              DATETIME2     NULL,
    CompletedAt            DATETIME2     NULL,
    CONSTRAINT PK_Progresses PRIMARY KEY (Id),
    CONSTRAINT FK_Progresses_AspNetUsers_UserId
        FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE,
    CONSTRAINT FK_Progresses_Models_ModelId
        FOREIGN KEY (ModelId) REFERENCES Models (Id) ON DELETE NO ACTION -- Restrict
);
CREATE INDEX IX_Progresses_ModelId ON Progresses (ModelId);
CREATE INDEX IX_Progresses_UserId_Completed ON Progresses (UserId, Completed);
CREATE UNIQUE INDEX IX_Progresses_UserId_ModelId ON Progresses (UserId, ModelId);

CREATE TABLE Ratings (
    Id      INT IDENTITY(1,1) NOT NULL,
    UserId  NVARCHAR(450) NOT NULL,
    ModelId INT           NOT NULL,
    Stars   INT           NOT NULL, -- 1..5
    RatedAt DATETIME2     NOT NULL,
    CONSTRAINT PK_Ratings PRIMARY KEY (Id),
    CONSTRAINT FK_Ratings_AspNetUsers_UserId
        FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE,
    CONSTRAINT FK_Ratings_Models_ModelId
        FOREIGN KEY (ModelId) REFERENCES Models (Id) ON DELETE NO ACTION -- Restrict
);
CREATE INDEX IX_Ratings_ModelId ON Ratings (ModelId);
CREATE UNIQUE INDEX IX_Ratings_UserId_ModelId ON Ratings (UserId, ModelId);

CREATE TABLE UserAchievements (
    Id            INT IDENTITY(1,1) NOT NULL,
    UserId        NVARCHAR(450) NOT NULL,
    AchievementId INT           NOT NULL,
    UnlockedAt    DATETIME2     NOT NULL,
    CONSTRAINT PK_UserAchievements PRIMARY KEY (Id),
    CONSTRAINT FK_UserAchievements_AspNetUsers_UserId
        FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE,
    CONSTRAINT FK_UserAchievements_Achievements_AchievementId
        FOREIGN KEY (AchievementId) REFERENCES Achievements (Id) ON DELETE NO ACTION -- Restrict
);
CREATE INDEX IX_UserAchievements_AchievementId ON UserAchievements (AchievementId);
CREATE UNIQUE INDEX IX_UserAchievements_UserId_AchievementId ON UserAchievements (UserId, AchievementId);

-- ----------------------------------------------------------------------------
-- Seed data (from AppDbContext.OnModelCreating HasData)
-- ----------------------------------------------------------------------------

SET IDENTITY_INSERT Categories ON;
INSERT INTO Categories (Id, Name, Slug) VALUES
    (1, N'Animals',   N'animals'),
    (2, N'Birds',     N'birds'),
    (3, N'Flowers',   N'flowers'),
    (4, N'Dinosaurs', N'dinosaurs'),
    (5, N'Abstract',  N'abstract');
SET IDENTITY_INSERT Categories OFF;

SET IDENTITY_INSERT LevelDefinitions ON;
INSERT INTO LevelDefinitions (Level, RequiredExp, RankTitle) VALUES
    (1, 0,    N'Crane Apprentice'),
    (2, 100,  N'Crane Apprentice'),
    (3, 250,  N'Crane Apprentice'),
    (4, 500,  N'Crane Apprentice'),
    (5, 800,  N'Paper Artisan'),
    (6, 1200, N'Paper Artisan');
SET IDENTITY_INSERT LevelDefinitions OFF;

SET IDENTITY_INSERT Achievements ON;
INSERT INTO Achievements (Id, Code, Name, Description, IconUrl, ConditionText, ConditionType, Threshold) VALUES
    (1, N'first_fold', N'First Fold', N'Complete your first origami model.', N'',
     N'Complete 1 model', N'ModelsCompleted', 1);
SET IDENTITY_INSERT Achievements OFF;
