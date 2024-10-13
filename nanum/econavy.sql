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