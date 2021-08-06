require('ChapterVO, QWReadingVC, VolumeVO, VolumeCD, NSManagedObjectContext, QWReadingManager, BookPageVO')

defineClass('QWReadingManager', {
    saveReadingProgressWithReadingVC: function(readingVC) {
        var volume = self.currentVolumeVO();
        var volumeCD = self.currentVolumeCD();
        if (volumeCD == null) {
            volumeCD = VolumeCD().MR_createEntityInContext(NSManagedObjectContext().MR_defaultContext());
            volumeCD.updateWithVolumeVO(volume, self.bookCD.nid);
        }

        self.ORIGsaveReadingProgressWithReadingVC(readingVC);
    }

}, {});

