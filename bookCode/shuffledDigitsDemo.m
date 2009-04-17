%function digitsShuffle()
% visualize MNIST digits and version where we permute the pixels

load('mnistALL') % already randomly shuffled across classes
% train_images: [28x28x60000 uint8]
% test_images: [28x28x10000 uint8]
% train_labels: [60000x1 uint8]
% test_labels: [10000x1 uint8]

doPlot = 0;
if 1
  % to illustrate that shuffling the features does not affect classification performance
  perm  = randperm(28*28);
  mnist.train_images = reshape(mnist.train_images, [28*28 60000]);
  mnist.train_images = mnist.train_images(perm, :);
  mnist.train_images = reshape(mnist.train_images, [28 28 60000]);

  mnist.test_images = reshape(mnist.test_images, [28*28 10000]);
  mnist.test_images = mnist.test_images(perm, :);
  mnist.test_images = reshape(mnist.test_images, [28 28 10000]);
  doPlot = 0;
end


% test unpermuting
figure(1);clf;figure(2);clf; 
for i=1:9
  img =  mnist.test_images(:,:,i);
  y = mnist.test_labels(i);
  figure(1);
  subplot(3,3,i)
  imagesc(img);colormap(gray); axis off
  title(sprintf('true class = %d', y))
  
  img2(perm) = img(:);
  img2 = reshape(img2, [28 28]);
  figure(2);
  subplot(3,3,i)
  imagesc(img2); colormap(gray); axis off
  title(sprintf('true class = %d', y))
end

