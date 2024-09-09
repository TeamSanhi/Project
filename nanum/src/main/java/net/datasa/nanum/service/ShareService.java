package net.datasa.nanum.service;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.multipart.MultipartFile;

import jakarta.persistence.EntityNotFoundException;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.datasa.nanum.Util.FileManager;
import net.datasa.nanum.domain.dto.ShareBoardDTO;
import net.datasa.nanum.domain.entity.ImageEntity;
import net.datasa.nanum.domain.entity.MemberEntity;
import net.datasa.nanum.domain.entity.ShareBoardEntity;
import net.datasa.nanum.repository.ImageRepository;
import net.datasa.nanum.repository.MemberRepository;
import net.datasa.nanum.repository.ShareBoardRepository;

/**
 * shareService 클래스
 */
@Slf4j
@Service
@Transactional // 영속성
@RequiredArgsConstructor
public class ShareService {
    // shareBoradRepository 생성자 주입
    private final ShareBoardRepository shareBoardRepository;
    // MemberRepository 생성자 주입
    private final MemberRepository memberRepository;
    // imageRepository 생성자 주입
    private final ImageRepository imageRepository;
    // 파일저장을 위한 FileManager 생성자 주입
    private final FileManager fileManager;

    /**
     * shareSave 메소드
     * 
     * @param upload     업로드한 파일
     * @param uploadPath 파일 저장할 경로
     * @param DTO        저장할 글 정보
     * @throws IOException 데이터 저장시 필요
     */
    public void save(ShareBoardDTO DTO, String uploadPath, MultipartFile upload) throws IOException {
        // 글작성자가 테이블에 존재하는지 확인
        MemberEntity memberEntity = memberRepository.findById(DTO.getMemberNum())
                .orElseThrow(() -> new EntityNotFoundException("해당 회원이 존재하지 않습니다"));
        // ShareSave에서 받아온 DTO를 Entity로 변환
        ShareBoardEntity shareBoardEntity = ShareBoardEntity.builder()
                .shareTitle(DTO.getShareTitle())
                .shareContents(DTO.getShareContents())
                .shareLat(DTO.getShareLat())
                .shareLng(DTO.getShareLng())
                .member(memberEntity) // 찾은 글작성자를 외래키 member에 넣어줌
                .shareCompleted(false) // 나눔 확인상태 false로 초기화
                .reportCount(0) // 신고 수 0으로 초기화
                .bookmarkCount(0) // bookmark 수 0으로 초기화
                .imageFileName("image") // 이미지 이름 초기화
                .build();

        // 변환된 shareBoardEnetity를 저장
        shareBoardRepository.save(shareBoardEntity);

        // 첨부파일이 있는 경우 imageEntity로 변환
        if (upload != null && !upload.isEmpty()) {
            String fileName = fileManager.saveFile(uploadPath, upload);
            // imageEntity 생성 및 저장
            ImageEntity imageEntity = ImageEntity.builder()
                    .shareBoard(shareBoardEntity) // imageEntity의 외래키 shareBoardEntity
                    .imageFileName(fileName)
                    .build();
            // shareEntity에 imageFileNmae 저장
            shareBoardEntity.setImageFileName(fileName);
            // 생성된 imageEntity를 저장
            imageRepository.save(imageEntity);
        }
    }

    /**
     * 파일 다운로드
     * 
     * @param shareNum   글 번호
     * @param response   응답 정보
     * @param uploadPath 파일 저장 경로
     */
    public void download(Integer shareNum, HttpServletResponse response, String uploadPath) {
        // 전달된 글 번호로 글 정보 조회
        ShareBoardEntity shareBoardEntity = shareBoardRepository.findById(shareNum)
                .orElseThrow(() -> new EntityNotFoundException("게시글이 없습니다."));

        // response setHeader 설정
        response.setHeader("Content-Disposition", "attachment;filename=" + shareBoardEntity.getImageFileName());

        // 저장된 파일 경로와 파일 이름 합한다.
        String fullPath = uploadPath + "/" + shareBoardEntity.getImageFileName();

        // 서버의 파일을 읽을 입력 스트림과 클라이언트에게 전달할 출력스트림
        FileInputStream filein = null;
        ServletOutputStream fileout = null;

        try {
            filein = new FileInputStream(fullPath);
            fileout = response.getOutputStream();

            // Spring의 파일 관련 유틸 이용하여 출력
            FileCopyUtils.copy(filein, fileout);

            filein.close();
            fileout.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 글 상세 조회
     * 
     * @param shareNum 글 번호
     * @return ShareBoardDTO를 반환
     */
    public ShareBoardDTO read(Integer shareNum) {
        // 전달된 글 번호로 글 정보 조회
        ShareBoardEntity shareBoardEntity = shareBoardRepository.findById(shareNum)
                .orElseThrow(() -> new EntityNotFoundException("게시글이 없습니다."));

        // 전달된 게시글ShareBoardDTO로 변환해서 반환
        ShareBoardDTO shareBoardDTO = ShareBoardDTO.builder()
                .memberNum(shareBoardEntity.getMember().getMemberNum())
                .memberNickname(shareBoardEntity.getMember().getMemberNickname())
                .shareNum(shareBoardEntity.getShareNum())
                .shareTitle(shareBoardEntity.getShareTitle())
                .shareContents(shareBoardEntity.getShareContents())
                .shareDate(shareBoardEntity.getShareDate())
                .memberId(shareBoardEntity.getMember().getMemberId())
                .build();
        // DTO를 반환
        return shareBoardDTO;
    }

    /**
     * 게시글 삭제
     * 
     * @param shareNum   삭제할 글번호
     * @param username   로그인한 아이디
     * @param uploadPath 파일 저장경로
     */
    public void delete(int shareNum, String username, String uploadPath) {
        // 게시글의 존제여부 확인
        ShareBoardEntity shareBoardEntity = shareBoardRepository.findById(shareNum)
                .orElseThrow(() -> new EntityNotFoundException("게시글이 없습니다."));
        // 로그인 유저와 게시글 작성자가 일치하는지 확인
        if (!shareBoardEntity.getMember().getMemberId().equals(username)) {
            throw new RuntimeException("삭제 권한이 없습니다.");
        }
        // 첨부파일이 있는 경우 파일 삭제
        try {
            fileManager.deleteFile(uploadPath, shareBoardEntity.getImageFileName());
        } catch (Exception e) {
            e.printStackTrace();
        }
        // 게시글을 삭제
        shareBoardRepository.delete(shareBoardEntity);
    }

    /**
     * 게시글 수정
     * 
     * @param shareBoardDTO 수정할 글정보
     * @param username      로그인한 아이디
     * @param uploadPath    파일 저장할 경로
     * @param upload        업로드된 파일
     */
    public void edit(ShareBoardDTO shareBoardDTO, String username, String uploadPath, MultipartFile upload)
            throws Exception {
        // 게시글이 있는지 확인
        ShareBoardEntity shareBoardEntity = shareBoardRepository.findById(shareBoardDTO.getShareNum())
                .orElseThrow(() -> new EntityNotFoundException("게시글이 없습니다."));
        // 로그인한 유저와 게시글 작성자가 일치하는지 확인
        if (!shareBoardEntity.getMember().getMemberId().equals(username)) {
            throw new RuntimeException("수정 권한이 없습니다.");
        }
        // 전달된 정보 수정
        shareBoardEntity.setShareTitle(shareBoardDTO.getShareTitle());
        shareBoardEntity.setShareContents(shareBoardDTO.getShareContents());
        shareBoardEntity.setShareLat(shareBoardDTO.getShareLat());
        shareBoardEntity.setShareLng(shareBoardDTO.getShareLng());
        // debug
        log.debug("수정된 shareBoardEntity", shareBoardEntity);
        // 업로드된 파일이 있으면 기존 파일 삭제하고 새로 저장
        if (upload != null && !upload.isEmpty()) {
            if (shareBoardEntity.getImageFileName() != null) {
                fileManager.deleteFile(uploadPath, shareBoardEntity.getImageFileName());
            }
            String fileName = fileManager.saveFile(uploadPath, upload);
            shareBoardEntity.setImageFileName(fileName);
        }
    }

    /**
     * 나눔글 수 합산
     * 
     * @param memberNum 멤버 엔티티
     * @return 멤버 나눔글 수 합산
     */
    public Integer getShareCount(MemberEntity memberNum) {
        Integer shareCount = shareBoardRepository.shareCount(memberNum);
        return shareCount;
    }

    /*
     * ajax로 지도가 변할때 마다 지도에 표시되는 게시글을 업데이트 하며 게시판으로 보여줌으로 필요없어 졌음으로 경로의 역할만 한다.
     * 고로 모든 게시글 목록을 불러오는 이 함수는 필요가 없다.
     * public List<ShareBoardDTO> getListAll() {
     * Sort sort = Sort.by(Sort.Direction.DESC, "shareNum");
     * // 전체 보기
     * List<ShareBoardEntity> entityList = shareBoardRepository.findAll(sort);
     * log.debug("전체 글목록 조회 : {}", entityList);
     * // DTO로 변환할 리스트 생성
     * List<ShareBoardDTO> dtoList = new ArrayList<>();
     * // entityList를 DTO로 변환해서 dtoList에 저장
     * for (ShareBoardEntity entity : entityList) {
     * ShareBoardDTO dto = ShareBoardDTO.builder()
     * .memberNum(entity.getMember().getMemberNum()) // memberNum을 가져오기 위해서
     * // entity.getMember().getMemberNum() 사용
     * .shareTitle(entity.getShareTitle())
     * .memberNickname(entity.getMember().getMemberNickname()) // 테이블에 없는 닉네임 DTO 따로
     * 만들어 Nickname 저장
     * .shareDate(entity.getShareDate())
     * .shareNum(entity.getShareNum())
     * .imageFileName(entity.getImageFileName())
     * .build();
     * dtoList.add(dto);
     * }
     * // dtoList를 반환
     * return dtoList;
     * }
     */
}
