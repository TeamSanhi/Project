CREATE TABLE MEMBER (
    member_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 회원 번호
    member_id VARCHAR(20) NOT NULL, -- 회원 ID
    member_pw VARCHAR(100) NOT NULL, -- 회원 비밀번호    
    member_email VARCHAR(30) UNIQUE NOT NULL, -- 회원 이메일
    member_nickname VARCHAR(20) NOT NULL, -- 회원 닉네임
    member_file_name VARCHAR(100), -- 프로필 사진 이름
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 회원 가입일
    role_name VARCHAR(10) DEFAULT "ROLE_USER" CHECK (
        role_name IN ("ROLE_USER", "ROLE_ADMIN")
    ), -- 권한
    member_status INTEGER NOT NULL DEFAULT 0 CHECK (member_status IN (0, 1, 2)), -- 회원 상태
    quit_date TIMESTAMP, -- 계정 삭제일 	
    member_point INTEGER DEFAULT 0 -- 회원 포인트
);

CREATE TABLE SHARE_BOARD (
    share_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 게시글 번호
    member_num INTEGER, -- 작성자 번호
    receiver_num INTEGER, -- 수령자 번호
    share_title VARCHAR(200) NOT NULL, -- 게시글 제목
    share_contents TEXT NOT NULL, -- 게시글 내용
    share_lat DOUBLE NOT NULL, -- 나눔 장소 위도
    share_lng DOUBLE NOT NULL, -- 나눔 장소 경도
    share_completed TINYINT(1) DEFAULT 0 CHECK (share_completed IN (0, 1)), -- 나눔 완료 여부
    share_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 게시글 등록일
    report_count INTEGER DEFAULT 0, -- 신고 횟수: 3번 이상 신고당하면 삭제
    bookmark_count INTEGER DEFAULT 0, -- 북마크 개수
    CONSTRAINT FOREIGN KEY (member_num) REFERENCES MEMBER (member_num) ON DELETE SET NULL,
    CONSTRAINT FOREIGN KEY (receiver_num) REFERENCES MEMBER (member_num) ON DELETE SET NULL
);

CREATE TABLE BOOKMARK (
    bookmark_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 북마크 키
    member_num INTEGER, -- 회원 번호
    share_num INTEGER, -- 게시글 번호
    CONSTRAINT FOREIGN KEY (member_num) REFERENCES MEMBER (member_num) ON DELETE CASCADE,
    CONSTRAINT FOREIGN KEY (share_num) REFERENCES SHARE_BOARD (share_num) ON DELETE CASCADE
);

CREATE TABLE ROOM (
    room_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 쪽지방 번호
    creator_num INTEGER, -- 방 생성자 번호
    receiver_num INTEGER, -- 게시글 주인 번호
    share_num INTEGER, -- 게시글 번호
    CONSTRAINT FOREIGN KEY (creator_num) REFERENCES MEMBER (member_num) ON DELETE SET NULL,
    CONSTRAINT FOREIGN KEY (receiver_num) REFERENCES MEMBER (member_num) ON DELETE SET NULL,
    CONSTRAINT FOREIGN KEY (share_num) REFERENCES SHARE_BOARD (share_num) ON DELETE CASCADE
);

CREATE TABLE MESSAGE (
    message_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 쪽지 번호
    sender_num INTEGER, -- 발신자 번호
    room_num INTEGER, -- 쪽지방 번호
    message_contents TEXT NOT NULL, -- 쪽지 내용
    deliver_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 전송일
    is_read TINYINT(1) DEFAULT 0 CHECK (is_read in (0, 1)), -- 읽음 여부		
    CONSTRAINT FOREIGN KEY (sender_num) REFERENCES MEMBER (member_num) ON DELETE SET NULL,
    CONSTRAINT FOREIGN KEY (room_num) REFERENCES ROOM (room_num) ON DELETE SET NULL
);

CREATE TABLE RECYCLE_BOARD (
    recycle_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 목록 번호
    recycle_file_name VARCHAR(100) NOT NULL, -- 이미지
    recycle_category VARCHAR(50) NOT NULL, -- 카테고리
    recycle_name VARCHAR(50) NOT NULL, -- 이름
    recycle_possible VARCHAR(10) NOT NULL, -- 재활용 여부
    recycle_contents TEXT NOT NULL, -- 분리수거 규정
    view_count INTEGER DEFAULT 0, -- 조회수
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- 갱신일
);

CREATE TABLE SEARCHWORD (
    search_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 검색 목록 번호
    member_num INTEGER, -- 회원 번호
    search_word VARCHAR(20) NOT NULL, -- 검색어
    CONSTRAINT FOREIGN KEY (member_num) REFERENCES MEMBER (member_num) ON DELETE CASCADE
);

CREATE TABLE ALARM (
    alarm_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 알림 번호
    member_num INTEGER, -- 회원 번호
    alarm_day INTEGER CHECK (
        alarm_day IN (0, 1, 2, 3, 4, 5, 6)
    ), -- 요일
    alarm_contents VARCHAR(30), -- 알림 내용
    CONSTRAINT FOREIGN KEY (member_num) REFERENCES MEMBER (member_num) ON DELETE CASCADE
);

CREATE TABLE IMAGE (
    image_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 사진 목록 번호
    share_num INTEGER, -- 게시글 번호
    image_file_name VARCHAR(100) NOT NULL, -- 사진 파일
    CONSTRAINT FOREIGN KEY (share_num) REFERENCES SHARE_BOARD (share_num) ON DELETE CASCADE
);

CREATE TABLE REPORT (
    report_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 신고 이력 번호
    member_num INTEGER, -- 신고 대상 번호
    reporter_num INTEGER, -- 신고자 번호
    report_reason TEXT NOT NULL, -- 신고 사유
    CONSTRAINT FOREIGN KEY (member_num) REFERENCES MEMBER (member_num) ON DELETE CASCADE,
    CONSTRAINT FOREIGN KEY (reporter_num) REFERENCES MEMBER (member_num) ON DELETE SET NULL
);

CREATE TABLE Report_board (
    report_board_num INTEGER AUTO_INCREMENT PRIMARY KEY, -- 게시글 신고 이력
    member_num INTEGER, -- 신고 대상 번호
    share_num INTEGER, -- 신고 게시글 번호
    CONSTRAINT FOREIGN KEY (member_num) REFERENCES MEMBER (member_num) ON DELETE CASCADE,
    CONSTRAINT FOREIGN KEY (share_num) REFERENCES SHARE_BOARD (share_num) ON DELETE CASCADE
)

INSERT INTO
    recycle_board (
        recycle_file_name,
        recycle_category,
        recycle_name,
        recycle_possible,
        recycle_contents,
        view_count,
        update_date
    )
VALUES (
        'image1.png',
        '골판지류',
        '골판지 상자',
        '재활용 O',
        '배출방법 : 비닐코팅 부분 상자에 붙어있는 테이프·철핀 알루미늄박 등을 제거하고 접어서 배출 야외 별도 보관 장소 마련 등 다른 종이류와 섞이지 않게 배출 ※ 비해당품목: 택배용 보냉 상자류 등 내부에 알루미늄박, 비닐 등이 부착되어 종이와 분리되지 않는 상자류',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image2.png',
        '골판지 외 종이류',
        '우유팩',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하고 말린 후 배출 빨대 비닐 등 종이팩과 다른 재질은 제거한 후 배출 - 다른 종이류와 혼합되지 않게 종이팩 전용수거함에 배출 종이팩 전용수거함이 없는 경우에는 종이류와 구분할 수 있도록 가급적 끈 등으로 묶어 종이류 수거함으로 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image3.png',
        '골판지 외 종이류',
        '소주팩',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하고 말린 후 배출 빨대 비닐 등 종이팩과 다른 재질은 제거한 후 배출 - 다른 종이류와 혼합되지 않게 종이팩 전용수거함에 배출 종이팩 전용수거함이 없는 경우에는 종이류와 구분할 수 있도록 가급적 끈 등으로 묶어 종이류 수거함으로 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image4.png',
        '골판지 외 종이류',
        '쥬스팩',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하고 말린 후 배출 빨대 비닐 등 종이팩과 다른 재질은 제거한 후 배출 - 다른 종이류와 혼합되지 않게 종이팩 전용수거함에 배출 종이팩 전용수거함이 없는 경우에는 종이류와 구분할 수 있도록 가급적 끈 등으로 묶어 종이류 수거함으로 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image5.png',
        '골판지 외 종이류',
        '신문지',
        '재활용 O',
        '배출방법 : 물기에 젖지 않도록 하고 반듯하게 펴서 차곡차곡 쌓은 후 묶어서 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image6.png',
        '골판지 외 종이류',
        '책자',
        '재활용 O',
        '배출방법 : 비닐 코팅된 종이 공책의 스프링 비닐포장지 등은 제거 후 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image7.png',
        '골판지 외 종이류',
        '노트',
        '재활용 O',
        '배출방법 : 비닐 코팅된 종이 공책의 스프링 비닐포장지 등은 제거 후 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image8.png',
        '골판지 외 종이류',
        '전단지',
        '재활용 O',
        '배출방법 : 비닐 코팅된 종이 공책의 스프링 비닐포장지 등은 제거 후 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image9.png',
        '골판지 외 종이류',
        '종이컵',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹군 후 압착하여 봉투에 넣거나 한데 묶어서 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image10.png',
        '기타 종이류',
        '기타 종이류',
        '재활용 O',
        '배출방법 : 물기에 젖이 않도록 하고 크기별로 반듯하게 펴서 차곡차곡 쌓은 후 묶어서 배출 ※ 비해당품목: 알루미늄 등 금속이 박힌 복합소재 종이 택배전표 영수증 감열지 사진용지 기름때가 묻은 종이 호일 사용한 화장지 방수 가공 포스터 등',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image11.png',
        '유리병',
        '음료수병',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 담배꽁초 등 이물질을 넣지 않고 배출 유리병이 깨지지 않도록 주의하여 배출 색상별 용기가 설치되어 색상별로 배출이 가능한 경우 분리 배출 접착제로 부착되지 아니하여 상표제거가 가능한 경우 상표를 제거한 후 배출 소주 맥주 등 빈용기보증금 대상 유리병은 소매점 등으로 반납하여 보증금 환급',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image12.png',
        '유리병',
        '기타 병류',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 담배꽁초 등 이물질을 넣지 않고 배출 유리병이 깨지지 않도록 주의하여 배출 색상별 용기가 설치되어 색상별로 배출이 가능한 경우 분리 배출 접착제로 부착되지 아니하여 상표제거가 가능한 경우 상표를 제거한 후 배출 소주 맥주 등 빈용기보증금 대상 유리병은 소매점 등으로 반납하여 보증금 환급 ※ 비해당품목: 깨진 유리제품(신문지 등에 싸서 종량제 봉투에 배출) 코팅 및 다양한 색상이 들어간 유리제품 내열 유리제품 크리스탈 유리제품 판유리 조명기구용 유리류 사기·도자기류 등(특수규격마대 또는 대형폐기물 처리 등 지자체 조례에 따라 배출)',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image13.png',
        '금속캔',
        '음료캔',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 담배꽁초 등 이물질을 넣지 않고 배출 플라스틱 뚜껑 등 금속캔과 다른 재질은 제거한 후 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image14.png',
        '금속캔',
        '주류캔',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 담배꽁초 등 이물질을 넣지 않고 배출 플라스틱 뚜껑 등 금속캔과 다른 재질은 제거한 후 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image15.png',
        '금속캔',
        '식료품캔',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 담배꽁초 등 이물질을 넣지 않고 배출 플라스틱 뚜껑 등 금속캔과 다른 재질은 제거한 후 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image16.png',
        '금속캔',
        '부탄가스 캔',
        '재활용 O',
        '배출방법 : 내용물을 제거한 후 배출 ※가스용기는 가급적 통풍이 잘되는 장소에서 노즐을 누르는 등 내용물을 완전히 제거한 후 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image17.png',
        '금속캔',
        '스프레이 용기',
        '재활용 O',
        '배출방법 : 내용물을 제거한 후 배출 ※가스용기는 가급적 통풍이 잘되는 장소에서 노즐을 누르는 등 내용물을 완전히 제거한 후 배출 ※ 비해당품목: 내용물이 남아있는 캔류(락카 페인트통 등)는 특수규격마대 등 지자체 조례에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image18.png',
        '무색 폴리 에틸렌 테레프탈레이트(PET병)',
        '무색 투명한 먹는 샘물',
        '재활용 O',
        '배출방법 : 내용물을 깨끗이 비우고 부착상표(라벨)등을 제거한 후 가능한 압착하여 뚜껑을 닫아 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image19.png',
        '폴리에틸렌테레프탈레이트(PET)병',
        '기타 병류',
        '재활용 O',
        '배출방법 : 내용물을 깨끗이 비우고 부착상표(라벨)등을 제거한 후 가능한 압착하여 뚜껑을 닫아 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image20.png',
        '합성수지 용기',
        '음료용기',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 ※물로 헹굴 수 없는 구조의 용기류(치약용기 등)는 내용물을 비운 후 배출, 부착상표 부속품 등 본체와 다른 재질은 제거한 후 배출, 펌핑용기의 경우 내부 철제 스프링이 부착된 펌프는 제거하여 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image21.png',
        '합성수지 용기',
        '세정용기',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 ※물로 헹굴 수 없는 구조의 용기류(치약용기 등)는 내용물을 비운 후 배출, 부착상표 부속품 등 본체와 다른 재질은 제거한 후 배출, 펌핑용기의 경우 내부 철제 스프링이 부착된 펌프는 제거하여 배출 ※ 비해당품목: 플라스틱 이외의 재질이 부착된 완구·문구류 옷걸이 칫솔 파일철 전화기 낚싯대 유모차·보행기 CD·DVD 여행용 트렁크 골프가방 등은 종량제봉투 특수규격마대 또는 대형폐기물 처리 등 지자체 조례에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image22.png',
        '합성수지 비닐류',
        '비닐포장재',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 흩날리지 않도록 봉투에 담아 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image23.png',
        '합성수지 비닐류',
        '1회용 비닐봉투',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 흩날리지 않도록 봉투에 담아 배출 ※ 필름·시트형 랩필름 각 포장재의 표면적이 50㎠ 미만 내용물의 용량이 30㎖ 또는 30g이하인 포장재 등 분리배출 표시를 할 수 없는 포장재 포함 ※ 비해당 품목: 깨끗하게 이물질 제거가 되지 않은 랩필름 식탁보 고무장갑 장판 돗자리 섬유류 등(천막 현수막 의류 침구류 등)은 종량제봉투 특수규격마대 또는 대형폐기물 처리 등 지자체 조례에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image24.png',
        '발포 합성수지(스티로폼 완충제)',
        '농·수·축산물 포장용 발포스티렌상자',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 부착상표 등 스티로폼과 다른 재질은 제거한 후 배출 TV 등 전자제품 구입 시 완충재로 사용되는 발포합성수지 포장재는 가급적 구입처로 반납',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image25.png',
        '전자제품 완충재로 사용되는 발포합성수지포장재',
        '전자제품 완충재로 사용되는 발포합성수지포장재',
        '재활용 O',
        '배출방법 : 내용물을 비우고 물로 헹구는 등 이물질을 제거하여 배출 부착상표 등 스티로폼과 다른 재질은 제거한 후 배출 TV 등 전자제품 구입 시 완충재로 사용되는 발포합성수지 포장재는 가급적 구입처로 반납. ※ 비해당 품목: 타 재질과 코팅 또는 접착된 발포스티렌, 건축용 내·외장재 스티로폼, 음식물이 묻어 있거나 이물질을 제거하기 어려운 경우등은 종량제봉투, 특수규격마대 또는 대형폐기물 처리 등 지자체 조례에 따라 배출은 종량제봉투, 특수규격마대에 넣어 배출하거나 대형폐기물로 처리하는 등 지방자치단체 조례에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image26.png',
        '의류 및 원단류',
        '면 의류',
        '재활용 O',
        '배출방법 : 지자체 또는 민간 재활용사   업자가 비치한 폐의류 전용수거함에 배출하거나 문전수거 지역 등에서는 물기에 젖지 않도록 마대 등에 담거나 묶어서 대문 앞 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image27.png',
        '의류 및 원단류',
        '식물성 섬유(면 마 등)',
        '재활용 O',
        '배출방법 : 지자체 또는 민간 재활용사업자가 비치한 폐의류 전용수거함에 배출하거나 문전수거 지역 등에서는 물기에 젖지 않도록 마대 등에 담거나 묶어서 대문 앞 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image28.png',
        '의류 및 원단류',
        '합성섬유(폴리에스테르 나일론 아크릴 폴리우레탄 등)',
        '재활용 O',
        '배출방법 : 지자체 또는 민간 재활용사업자가 비치한 폐의류 전용수거함에 배출하거나 문전수거 지역 등에서는 물기에 젖지 않도록 마대 등에 담거나 묶어서 대문 앞 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image29.png',
        '전지류',
        '수은전지',
        '재활용 O',
        '배출방법 : 전지를 제품에서 분리하여 배출 전자제품 대리점 및 시계점 등 역회수 루트를 통하여 배출 주요 거점에 비치된 수거함에 배출하거나 지정된 전지류 수거일·장소에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image30.png',
        '전지류',
        '산화은전지',
        '재활용 O',
        '배출방법 : 전지를 제품에서 분리하여 배출 전자제품 대리점 및 시계점 등 역회수 루트를 통하여 배출 주요 거점에 비치된 수거함에 배출하거나 지정된 전지류 수거일·장소에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image31.png',
        '전지류',
        '니켈·카드뮴전지',
        '재활용 O',
        '배출방법 : 전지를 제품에서 분리하여 배출. 전자제품 대리점 및 시계점 등 역회수 루트를 통하여 배출. 주요 거점에 비치된 수거함에 배출하거나 지정된 전지류 수거일·장소에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image32.png',
        '전지류',
        '리튬 1차전지',
        '재활용 O',
        '배출방법 : 전지를 제품에서 분리하여 배출. 전자제품 대리점 및 시계점 등 역회수 루트를 통하여 배출. 주요 거점에 비치된 수거함에 배출하거나 지정된 전지류 수거일·장소에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image33.png',
        '전지류',
        '망간전지·알칼리망간전지',
        '재활용 O',
        '배출방법 : 전지를 제품에서 분리하여 배출. 전자제품 대리점 및 시계점 등 역회수 루트를 통하여 배출. 주요 거점에 비치된 수거함에 배출하거나 지정된 전지류 수거일·장소에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image34.png',
        '전지류',
        '니켈 수소전지',
        '재활용 O',
        '배출방법 : 전지를 제품에서 분리하여 배출. 전자제품 대리점 및 시계점 등 역회수 루트를 통하여 배출. 주요 거점에 비치된 수거함에 배출하거나 지정된 전지류 수거일·장소에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image35.png',
        '형광등',
        '직관형(FL) 형광등',
        '재활용 O',
        '배출방법 : 지자체별 형광등 분리배출용기에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image36.png',
        '형광등',
        '환형(FCL) 형광등',
        '재활용 O',
        '배출방법 : 지자체별 형광등 분리배출용기에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image37.png',
        '형광등',
        '안정기 내장형(CFL) 형광등',
        '재활용 O',
        '배출방법 : 지자체별 형광등 분리배출용기에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image38.png',
        '형광등',
        '콤팩트형(FPL) 형광등',
        '재활용 O',
        '배출방법 : 지자체별 형광등 분리배출용기에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image39.png',
        '형광등',
        '기타 수은을 함유한 조명제품',
        '재활용 O',
        '배출방법 : 지자체별 형광등 분리배출용기에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image40.png',
        '고철류',
        '고철(공기구 철사 못 등)',
        '재활용 O',
        '배출방법 : 이물질이 섞이지 않도록 한 후 봉투에 넣거나 끈으로 묶어서 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image41.png',
        '고철류',
        '비철금속(알미늄 스텐류 등)',
        '재활용 O',
        '배출방법 : 이물질이 섞이지 않도록 한 후 봉투에 넣거나 끈으로 묶어서 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image42.png',
        '영농 폐기물류',
        '농약용기',
        '재활용 O',
        '배출방법 : 내용물을 완전히 사용한 후 마을공동집하장 또는 수거·운반차량 진입이 가능한 일정 장소에 보관',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image43.png',
        '영농 폐기물류',
        '농촌폐비닐',
        '재활용 O',
        '배출방법 : 흙과 자갈 잡초를 털어낸 후 운반이 쉽도록 묶어서 마을공동집하장 또는 수거·운반차량 진입이 가능한 일정 장소에 보관',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image44.png',
        '소형 가전제품 및 이차전지류',
        '휴대폰, 카메라',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image45.png',
        '소형 가전제품 및 이차전지류',
        'MP3',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image46.png',
        '소형 가전제품 및 이차전지류',
        'PMP',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image47.png',
        '소형 가전제품 및 이차전지류',
        '게임기',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출 ',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image48.png',
        '소형 가전제품 및 이차전지류',
        '전자사전',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image49.png',
        '소형 가전제품 및 이차전지류',
        '믹서기',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image50.png',
        '소형 가전제품 및 이차전지류',
        '네비게이션',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image51.png',
        '소형 가전제품 및 이차전지류',
        '스탠드',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image52.png',
        '소형 가전제품 및 이차전지류',
        '헤어드라이',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image53.png',
        '소형 가전제품 및 이차전지류',
        '전자제품내 리튬이차전지 보조배터리',
        '재활용 O',
        '배출방법 : 지자체별 소형가전제품 분리수거함에 배출 ※ 스탠드는 몸체에서 형광등을 분리하여 배출. 소형가전제품 분리수거함이나 주요거점에 비치된 배터리 수거함에 테이핑 작업 혹은 비닐팩 밀봉 후 배출. ※ 역회수 루트를 통한 회수방안 등 지자체 실정에 맞게 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image54.png',
        '전자제품',
        'TV',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image55.png',
        '전자제품',
        '냉장고',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image56.png',
        '전자제품',
        '세탁기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image57.png',
        '전자제품',
        '에어컨',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image58.png',
        '전자제품',
        '자동판매기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image59.png',
        '전자제품',
        '컴퓨터',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image60.png',
        '전자제품',
        '프린터',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image61.png',
        '전자제품',
        '복사기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image62.png',
        '전자제품',
        '팩시밀리',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image63.png',
        '전자제품',
        '전기정수기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image64.png',
        '전자제품',
        '전기오븐',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image65.png',
        '전자제품',
        '전자레인지',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image66.png',
        '전자제품',
        '음식물처리기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image67.png',
        '전자제품',
        '식기건조기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image68.png',
        '전자제품',
        '전기비데',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image69.png',
        '전자제품',
        '공기청정기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image70.png',
        '전자제품',
        '전기히터',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image71.png',
        '전자제품',
        '오디오',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image72.png',
        '전자제품',
        '전기밥솥',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image73.png',
        '전자제품',
        '연수기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image74.png',
        '전자제품',
        '가습기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image75.png',
        '전자제품',
        '전기다리미',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image76.png',
        '전자제품',
        '선풍기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image77.png',
        '전자제품',
        '믹서기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image78.png',
        '전자제품',
        '청소기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image79.png',
        '전자제품',
        '비디오플레이어',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수 대형폐기물관리에 관한 수거체계에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image80.png',
        '전자제품',
        '이동전화단말기',
        '재활용 O',
        '배출방법 : 판매업자가 신제품 판매시 무상으로 역회수 또는 폐전자제품 무상 방문수거를 통한 회수. ※휴대폰은 전지를 분리하지 말고 본체·충전기와 함께 신제품 교환시에 해당 대리점을 통하여 배출하거나 소형가전제품 분리배출요령에 따라 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image81.png',
        '타이어',
        '소형 중형 대형 타이어',
        '재활용 O',
        '배출방법 : 정비업소 타이어판매소 등 역회수 루트를 통하여 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image82.jpg',
        '자동차 부품',
        '폐납산배터리',
        '재활용 O',
        '배출방법 : 지자체가 마련한 수거장소 또는 자동차 정비업소 등에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image83.png',
        '식용유',
        '폐식용유',
        '재활용 O',
        '배출방법 : 이물질이 섞이지 않게 모아 지자체 또는 민간 재활용사업자가 마련한 수거장소 전용수거함 등에 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image84.png',
        '윤활유',
        '윤활유',
        '재활용 O',
        '배출방법 : 정비업소 등 역회수 루트를 통하여 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image85.png',
        '윤활유 용기',
        '윤활유 용기',
        '재활용 O',
        '배출방법 : 정비업소 등 역회수 루트를 통하여 배출',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image86.png',
        '종이류',
        '내부에 알루미늄박이나 비닐 등이 부착되어 종이와 분리되지 않는 상자류',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image87.png',
        '종이류',
        '택배용 보냉 상자',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image88.png',
        '종이류',
        '알루미늄 코팅 박스',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image89.jpg',
        '종이류',
        '알루미늄 등 금속이 박힌 복합소재 종이',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image90.png',
        '종이류',
        '택배전표',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image91.png',
        '종이류',
        '영수증 감열지',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image92.png',
        '종이류',
        '사진용지',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image93.jpg',
        '종이류',
        '기름때가 묻은 종이 호일',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image94.png',
        '종이류',
        '사용한 화장지',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image95.png',
        '종이류',
        '방수 가공 포스터',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image96.png',
        '유리류',
        '깨진 유리제품',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image97.png',
        '유리류',
        '깨진 유리잔',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image98.png',
        '유리류',
        '깨진 유리병',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image99.png',
        '유리류',
        '코팅된 유리제품',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image100.png',
        '유리류',
        '다양한 색상이 들어간 유리제품',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image101.png',
        '유리류',
        '내열 유리제품',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image102.png',
        '유리류',
        '내열 유리 냄비',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image103.png',
        '유리류',
        '오븐용 유리 그릇',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image104.png',
        '유리류',
        '크리스탈 유리제품',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image105.png',
        '유리류',
        '판유리',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image106.png',
        '유리류',
        '창문 유리',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image107.png',
        '유리류',
        '거울',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image108.png',
        '유리류',
        '조명기구용 유리류',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image109.png',
        '유리류',
        '전구 커버',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image110.png',
        '유리류',
        '조명등 유리',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image111.png',
        '사기/도자기류',
        '사기·도자기류',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image112.png',
        '사기/도자기류',
        '도자기 그릇',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image113.png',
        '사기/도자기류',
        '사기 접시',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image114.png',
        '금속류 및 복합재',
        '내용물이 남아있는 캔류',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image115.png',
        '금속류 및 복합재',
        '남은 페인트통',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image116.png',
        '금속류 및 복합재',
        '락카 스프레이 캔',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image117.png',
        '금속류 및 복합재',
        '플라스틱 이외의 재질이 부착된 완구',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image118.png',
        '금속류 및 복합재',
        '금속 부품이 있는 장난감',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image119.png',
        '금속류 및 복합재',
        '천 소재가 포함된 장난감',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image120.png',
        '금속류 및 복합재',
        '플라스틱 이외의 재질이 부착된 문구류',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image121.png',
        '금속류 및 복합재',
        '철제 스프링이 있는 공책',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image122.png',
        '금속류 및 복합재',
        '금속 클립이 부착된 파일',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image123.png',
        '금속류 및 복합재',
        '옷걸이',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image124.png',
        '금속류 및 복합재',
        '철제 옷걸이',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    ),
    (
        'image125.png',
        '금속류 및 복합재',
        '나무 옷걸이',
        '재활용X',
        '재활용 불가입니다.',
        0,
        CURRENT_TIMESTAMP
    );