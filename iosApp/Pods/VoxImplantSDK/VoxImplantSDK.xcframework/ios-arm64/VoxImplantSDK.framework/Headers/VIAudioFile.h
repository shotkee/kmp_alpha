/*
 *  Copyright (c) 2011-2021, Zingaya, Inc. All rights reserved.
 */

NS_ASSUME_NONNULL_BEGIN

@protocol VIAudioFileDelegate;

/**
 * A file player that automatically prepares audio session and plays sounds.
 *
 * Supported file formats are: .caf, .wav, .aiff, .aifc, .mp3, .ac3
 *
 * Limitations:
 * - Playing audio file is not supported while there is an active connected call.
 * - Playing audio file may be interrupted if audio within a call is started.
 * - Playing audio file will be stopped if Siri or CallKit is activated.
 *
 * @namespace hardware
 */
@interface VIAudioFile : NSObject

/**
 * Initialize audio file instance.
 *
 * @param audioFileURL Audio file URL.
 * @param looped YES to play audio file repeatedly. NO to play once.
 *
 * @return VIAudioFile instance or nil if url is not valid or unsupported format is used.
 */
- (nullable instancetype)initWithURL:(NSURL *)audioFileURL looped:(BOOL)looped;

/**
 * Initialize audio file instance.
 *
 * @param audioFileData Audio file Data.
 * @param looped YES to play audio file repeatedly. NO to play once.
 *
 * @return VIAudioFile instance or nil if audio file data is not valid or unsupported format is used.
 */
- (nullable instancetype)initWithData:(NSData *)audioFileData looped:(BOOL)looped;

/**
 * Audio file URL.
 */
@property(nonatomic, strong, readonly, nullable) NSURL *url;

/**
 * Indicates if the audio file should be played repeatedly or once.
 */
@property(nonatomic, assign) BOOL looped;

/**
 * All delegates methods will be called on this queue. Queue should be serial, but not concurrent (the main queue is applicable).
 *
 * If not specified, the main queue will be used.
 */
@property(nonatomic, strong, nullable) dispatch_queue_t delegateQueue;

/**
 * Delegate that handles events related to audio file playing process.
 */
@property(nonatomic, weak, nullable) id<VIAudioFileDelegate> delegate;

/**
 * Start to play the audio file repeatedly or once based on <[VIAudioFile looped]> property.
 *
 * If the audio file is already playing, calling this method will result in <[VIAudioFileDelegate audioFile:didStartPlaying:]> event with an error.
 */
- (void)play;

/**
 * Stop playing of the audio file.
 *
 * Calling this method has no effect if the audio file is not playing.
 */
- (void)stop;

@end


/**
 * Delegate that may be used to handle audio file events.
 *
 * @namespace hardware
 */
@protocol VIAudioFileDelegate <NSObject>

@optional

/**
 * Event is triggered to notify if the playing of the audio file is started successfully or failed with the error.
 *
 * @param audioFile Audio file that triggered the event.
 * @param playbackError Error with detailed information if playing failed to start or nil if it is started.
 */
- (void)audioFile:(VIAudioFile *)audioFile didStartPlaying:(nullable NSError *)playbackError;

/**
 * Event is triggered to notify that the playing of the audio file was stopped. Called only if <[VIAudioFileDelegate audioFile:didStartPlaying:]> was succeed.
 *
 * @param audioFile Audio file that triggered the event.
 * @param playbackError Error with detailed information if playing failed or nil if it is stopped successfully.
 */
- (void)audioFile:(nullable VIAudioFile *)audioFile didStopPlaying:(nullable NSError *)playbackError;

@end

NS_ASSUME_NONNULL_END
